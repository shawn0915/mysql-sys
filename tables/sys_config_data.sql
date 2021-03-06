-- Copyright (c) 2015 Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

-- NOTE: This needs to be replicated within the sys_config_clean.inc file

INSERT IGNORE INTO sys.sys_config (variable, value) VALUES
    ('statement_truncate_len', 10000),
    ('statement_performance_analyzer.limit', 100),
    ('statement_performance_analyzer.view', NULL),
    ('diagnostics.allow_i_s_tables', 'OFF'),
    ('diagnostics.include_raw', 'OFF');
