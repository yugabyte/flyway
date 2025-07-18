/*-
 * ========================LICENSE_START=================================
 * flyway-core
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
package org.flywaydb.core.internal.parser;

import lombok.CustomLog;
import lombok.Getter;
import lombok.Setter;
import org.flywaydb.core.api.FlywayException;
import org.flywaydb.core.api.configuration.Configuration;
import org.flywaydb.core.internal.nc.NativeConnectorsDatabase;
import org.flywaydb.core.internal.database.base.Database;
import org.flywaydb.core.internal.database.base.Schema;
import org.flywaydb.core.internal.resource.ResourceName;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@CustomLog
public class ParsingContext {
    private static final String DEFAULT_SCHEMA_PLACEHOLDER = "defaultSchema";
    private static final String USER_PLACEHOLDER = "user";
    private static final String DATABASE_PLACEHOLDER = "database";
    private static final String TIMESTAMP_PLACEHOLDER = "timestamp";
    private static final String FILENAME_PLACEHOLDER = "filename";
    private static final String WORKING_DIRECTORY_PLACEHOLDER = "workingDirectory";
    private static final String TABLE_PLACEHOLDER = "table";
    private static final String ENVIRONMENT_PLACEHOLDER = "environment";

    @Getter
    private final Map<String, String> placeholders = new HashMap<>();
    @Getter
    @Setter
    private Database database;

    private String generateName(String name, Configuration configuration) {
        return "flyway" + configuration.getPlaceholderSeparator() + name;
    }
    
    public void populate(final NativeConnectorsDatabase database, final Configuration configuration) {
        String defaultSchemaName = configuration.getDefaultSchema();
        final String[] schemaNames = configuration.getSchemas();
        if (defaultSchemaName == null) {
            if (schemaNames.length > 0) {
                defaultSchemaName = schemaNames[0];
            }
        }

        if (defaultSchemaName != null) {
            placeholders.put(generateName(DEFAULT_SCHEMA_PLACEHOLDER,configuration), defaultSchemaName);
        }

        if (database.getDatabaseMetaData().databaseName() != null) {
            placeholders.put(generateName(DATABASE_PLACEHOLDER,configuration), database.getDatabaseMetaData().databaseName());
        }

        placeholders.put(generateName(USER_PLACEHOLDER,configuration), database.getCurrentUser());
        placeholders.put(generateName(TIMESTAMP_PLACEHOLDER,configuration), new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        placeholders.put(generateName(WORKING_DIRECTORY_PLACEHOLDER,configuration), System.getProperty("user.dir"));
        placeholders.put(generateName(TABLE_PLACEHOLDER,configuration), configuration.getTable());
        placeholders.put(generateName(ENVIRONMENT_PLACEHOLDER, configuration), configuration.getCurrentEnvironmentName());
    }

    public void populate(Database database, Configuration configuration) {
        setDatabase(database);

        String defaultSchemaName = configuration.getDefaultSchema();
        String[] schemaNames = configuration.getSchemas();

        Schema currentSchema = getCurrentSchema(database);
        String catalog = database.getCatalog();
        String currentUser = getCurrentUser(database);

        // cf. Flyway.prepareSchemas()
        if (defaultSchemaName == null) {
            if (schemaNames.length > 0) {
                defaultSchemaName = schemaNames[0];
            } else {
                defaultSchemaName = currentSchema.getName();
            }
        }

        if (defaultSchemaName != null) {
            placeholders.put(generateName(DEFAULT_SCHEMA_PLACEHOLDER,configuration), defaultSchemaName);
        }

        if (catalog != null) {
            placeholders.put(generateName(DATABASE_PLACEHOLDER,configuration), catalog);
        }

        placeholders.put(generateName(USER_PLACEHOLDER,configuration), currentUser);
        placeholders.put(generateName(TIMESTAMP_PLACEHOLDER,configuration), new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
        placeholders.put(generateName(WORKING_DIRECTORY_PLACEHOLDER,configuration), configuration.getWorkingDirectory() != null ? configuration.getWorkingDirectory() :  System.getProperty("user.dir"));
        placeholders.put(generateName(TABLE_PLACEHOLDER,configuration), configuration.getTable());
        placeholders.put(generateName(ENVIRONMENT_PLACEHOLDER, configuration), configuration.getCurrentEnvironmentName());
    }

    public void updateFilenamePlaceholder(ResourceName resourceName, Configuration configuration) {
        String filenamePlaceholder = generateName(FILENAME_PLACEHOLDER, configuration);
        if (resourceName.isValid()) {
            placeholders.put(filenamePlaceholder, resourceName.getFilename());
        } else {
            placeholders.remove(filenamePlaceholder);
        }
    }

    private Schema getCurrentSchema(Database database) {
        try {
            return database.getMainConnection().getCurrentSchema();
        } catch (FlywayException e) {
            LOG.debug("Could not get schema for " + DEFAULT_SCHEMA_PLACEHOLDER + " placeholder.");
            return null;
        }
    }

    private String getCurrentUser(Database database) {
        try {
            return database.getCurrentUser();
        } catch (FlywayException e) {
            LOG.debug("Could not get user for " + USER_PLACEHOLDER + " placeholder.");
            return null;
        }
    }
}
