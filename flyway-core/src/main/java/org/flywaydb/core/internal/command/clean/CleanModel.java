/*
 * Copyright (C) Red Gate Software Ltd 2010-2024
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.flywaydb.core.internal.command.clean;

import lombok.Data;
import lombok.Getter;
import org.flywaydb.core.api.FlywayException;
import org.flywaydb.core.internal.command.clean.CleanModeConfigurationExtension.Mode;

import java.util.Arrays;

@Data
public class CleanModel {
    private SchemaModel schemas = null;
    @Getter
    private String mode = null;


    public void validate(){
        try {
            if(this.mode != null) {
                Mode.valueOf(this.mode);
            }
        } catch (IllegalArgumentException e) {
            throw new FlywayException("Unknown clean mode: " + mode);
        }
    }

    public void setMode(String mode) {
        this.mode = mode != null ? mode.toUpperCase() : null;
    }

    public void setCleanSchemasExclude(String... cleanSchemasExclude) {
        setSchemas(new SchemaModel());
        schemas.setExclude(Arrays.asList(cleanSchemasExclude));
    }
}