/*-
 * ========================LICENSE_START=================================
 * flyway-sqlserver
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
package org.flywaydb.database.sqlserver.fabricDataWarehouse;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.TimeZone;
import org.flywaydb.core.internal.database.InsertRowLock;
import org.flywaydb.core.internal.jdbc.JdbcTemplate;
import org.flywaydb.database.sqlserver.SQLServerDatabase;
import org.flywaydb.database.sqlserver.SQLServerSchema;
import org.flywaydb.database.sqlserver.SQLServerTable;

public class FabricDataWarehouseTable extends SQLServerTable {
    private final InsertRowLock insertRowLock;

    FabricDataWarehouseTable(JdbcTemplate jdbcTemplate, SQLServerDatabase database, String databaseName, SQLServerSchema schema, String name) {
        super(jdbcTemplate, database, databaseName, schema, name);
        this.insertRowLock = new InsertRowLock(jdbcTemplate);
    }

    @Override
    protected void doLock() throws SQLException {
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        Timestamp currentDateTime = new Timestamp(cal.getTime().getTime());

        String updateLockStatement = "UPDATE " + this + " SET installed_on = '" + currentDateTime + "' WHERE version = '?' AND description = 'flyway-lock'";
        String deleteExpiredLockStatement = "DELETE FROM " + this + " WHERE description = 'flyway-lock' AND installed_on < '?'";

        if (lockDepth == 0) {
            insertRowLock.doLock(database.getInsertStatement(this), updateLockStatement, deleteExpiredLockStatement, database.getBooleanTrue());
        }
    }

    @Override
    protected void doUnlock() throws SQLException {
        if (lockDepth == 1) {
            insertRowLock.doUnlock(getDeleteLockTemplate());
        }
    }

    private String getDeleteLockTemplate() {
        return "DELETE FROM " + this + " WHERE version = '?' AND description = 'flyway-lock'";
    }
}
