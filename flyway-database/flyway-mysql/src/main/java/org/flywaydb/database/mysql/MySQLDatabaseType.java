/*-
 * ========================LICENSE_START=================================
 * flyway-mysql
 * ========================================================================
 * Copyright (C) 2010 - 2025 Red Gate Software Ltd
 * ========================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================LICENSE_END==================================
 */
package org.flywaydb.database.mysql;

import static org.flywaydb.core.internal.util.UrlUtils.isAwsWrapperUrl;
import static org.flywaydb.core.internal.util.UrlUtils.isSecretManagerUrl;

import java.util.List;
import lombok.CustomLog;
import org.flywaydb.core.api.ResourceProvider;
import org.flywaydb.core.api.configuration.Configuration;
import org.flywaydb.authentication.mysql.MySQLOptionFileReader;

import org.flywaydb.core.extensibility.LicenseGuard;
import org.flywaydb.core.extensibility.Tier;
import org.flywaydb.core.internal.database.base.BaseDatabaseType;
import org.flywaydb.core.internal.database.base.Database;
import org.flywaydb.core.internal.jdbc.JdbcConnectionFactory;
import org.flywaydb.core.internal.jdbc.StatementInterceptor;
import org.flywaydb.core.internal.license.FlywayEditionUpgradeRequiredException;
import org.flywaydb.core.internal.parser.Parser;
import org.flywaydb.core.internal.parser.ParsingContext;
import org.flywaydb.core.internal.util.ClassUtils;
import org.flywaydb.core.internal.util.StringUtils;

import java.sql.Connection;
import java.sql.Types;
import java.util.Properties;

@CustomLog
public class MySQLDatabaseType extends BaseDatabaseType {
    private static final String MYSQL_LEGACY_JDBC_DRIVER = "com.mysql.jdbc.Driver";
    private static final String MARIADB_JDBC_DRIVER = "org.mariadb.jdbc.Driver";





    @Override
    public String getName() {
        return "MySQL";
    }

    @Override
    public List<String> getSupportedEngines() {
        //TODO - move TiDB to community plugin once this API is public
        return List.of(getName(), "PerconaXtraDbCluster", "TiDb", "AuroraMySql");
    }

    @Override
    public int getNullType() {
        return Types.VARCHAR;
    }

    @Override
    public boolean handlesJDBCUrl(String url) {
        return isSecretManagerUrl(url, "mysql")
            || url.startsWith("jdbc:mysql:") || url.startsWith("jdbc:google:")
            || url.startsWith("jdbc:p6spy:mysql:") || url.startsWith("jdbc:p6spy:google:")
            || isAwsWrapperUrl(url, "mysql");
    }

    @Override
    public String getDriverClass(String url, ClassLoader classLoader) {





        if (url.startsWith("jdbc:p6spy:mysql:") || url.startsWith("jdbc:p6spy:google:")) {
            return "com.p6spy.engine.spy.P6SpyDriver";
        }
        if (url.startsWith("jdbc:mysql:")) {
            return "com.mysql.cj.jdbc.Driver";
        }
        if (isAwsWrapperUrl(url, "mysql")) {
            return "software.amazon.jdbc.Driver";
        } else {
            return "com.mysql.jdbc.GoogleDriver";
        }
    }

    @Override
    public String getBackupDriverClass(String url, ClassLoader classLoader) {
        if (ClassUtils.isPresent(MYSQL_LEGACY_JDBC_DRIVER, classLoader)) {
            return MYSQL_LEGACY_JDBC_DRIVER;
        }

        if (ClassUtils.isPresent(MARIADB_JDBC_DRIVER, classLoader) && !url.contains("disableMariaDbDriver")) {
            return MARIADB_JDBC_DRIVER;
        }

        return null;
    }

    @Override
    public boolean handlesDatabaseProductNameAndVersion(String databaseProductName, String databaseProductVersion, Connection connection) {
        // Google Cloud SQL returns different names depending on the environment and the SDK version.
        //   ex.: Google SQL Service/MySQL
        return databaseProductName.contains("MySQL");
    }

    @Override
    public Database createDatabase(Configuration configuration, JdbcConnectionFactory jdbcConnectionFactory, StatementInterceptor statementInterceptor) {
        return new MySQLDatabase(configuration, jdbcConnectionFactory, statementInterceptor);
    }

    @Override
    public Parser createParser(Configuration configuration, ResourceProvider resourceProvider, ParsingContext parsingContext) {
        return new MySQLParser(configuration, parsingContext);
    }

    @Override
    public void setDefaultConnectionProps(String url, Properties props, ClassLoader classLoader) {
        props.put("connectionAttributes", "program_name:" + APPLICATION_NAME);
    }












    @Override
    public Properties getExternalAuthProperties(String url, String username) {
        MySQLOptionFileReader mySQLOptionFileReader = new MySQLOptionFileReader();

        mySQLOptionFileReader.populateOptionFiles();
        if (!mySQLOptionFileReader.optionFiles.isEmpty()) {
            LOG.info(org.flywaydb.core.internal.license.FlywayUpgradeMessage.generate("a MySQL option file", "use this for database authentication"));
        }
        return super.getExternalAuthProperties(url, username);







    }

    @Override
    public String instantiateClassExtendedErrorMessage() {
        return "Failure probably due to inability to load dependencies. Please ensure you have downloaded 'https://dev.mysql.com/downloads/connector/j/' and extracted to 'flyway/drivers' folder";
    }
}
