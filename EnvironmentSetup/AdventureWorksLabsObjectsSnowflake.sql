/*
 ** IMPORTANT: **
 ** If you don't have permissions to create databases or schemas,
 ** change these database and schemas statements and line 137 according to your objects.
 ** You can also create a trial account for this exercise if needed.
 ** 
*/

CREATE DATABASE ADVENTUREWORKS;
USE DATABASE ADVENTUREWORKS;
CREATE SCHEMA HUMANRESOURCES;
USE SCHEMA HUMANRESOURCES;

/****** Object:  Table vPowerBIEmployee ******/
CREATE TABLE vPowerBIEmployee (
  FirstName varchar(50)
  , LastName varchar(50)
  , JobTitle varchar(50)
  , BirthDate timestamp
  , Gender varchar(1)
  , Department varchar(50)
  , "Group Department" varchar(50)
);

/****** Object:  Table vPowerBISales ******/
CREATE TABLE vPowerBISales (
  SalesOrderID number(6)
  , CustomerID number(6)
  , SalesPersonID number(6)
  , TerritoryID number(6)
  , SubTotal number(10,4)
  , TaxAmt number(10,4)
  , Freight number(10,4)
  , TotalDue number(10,4)
  , OrderQty number(6)
  , UnitPrice number(10,4)
  , "Product Name" varchar(50)
  , "Territory Group Name" varchar(50)
  , "Territory Name" varchar(50)
  , "Product Sub Category Name" varchar(50)
  , "Product Category Name" varchar(50)
);

/****** Object:  File Format AdventureWorksCSV ******/
CREATE FILE FORMAT ADVENTUREWORKS_CSV 
    COMPRESSION = 'AUTO' 
    FIELD_DELIMITER = ',' 
    RECORD_DELIMITER = '\n' 
    SKIP_HEADER = 0 
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042' -- Double quoutes
    TRIM_SPACE = FALSE 
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
    ESCAPE = 'NONE' 
    ESCAPE_UNENCLOSED_FIELD = '\134' 
    DATE_FORMAT = 'AUTO' 
    TIMESTAMP_FORMAT = 'AUTO' 
    NULL_IF = ('NULL')
    VALIDATE_UTF8 = FALSE
;

/****** Object:  Procedure SP_PowerBIEmployee ******/
CREATE OR REPLACE PROCEDURE SP_PowerBIEmployee()
RETURNS string
LANGUAGE javascript
AS
$$

var _RS,_ROWS,ACTIVITY_COUNT,ROW_COUNT, MESSAGE_TEXT, SQLCODE, SQLSTATE, ERROR_HANDLERS;
var fetch = (count,rows,stmt) => count && rows.next() && Array.apply(null,Array(stmt.getColumnCount())).map((_,i) => rows.getColumnValue(i+1));
var INTO = function() { if (ROW_COUNT) return fetch(ROW_COUNT,_ROWS,_RS); else return [];};
var EXEC = function(stmt,binds,noCatch) {
    var fixBind = (arg) => arg == undefined ? null : arg instanceof Date ? arg.toISOString() : arg;
    binds = binds ? binds.map(fixBind) : (binds || []);
    try {
        _RS = snowflake.createStatement({sqlText: stmt, binds: binds});
        _ROWS = _RS.execute();
        ROW_COUNT = _RS.getRowCount();  ACTIVITY_COUNT = _RS.getNumRowsAffected();
    }
    catch (error) {
        MESSAGE_TEXT = error.message;
        SQLCODE = error.code;
        SQLSTATE = error.state;
        var errmsg = `${SQLCODE}:${SQLSTATE}:${MESSAGE_TEXT} STMT: ${stmt} ARGS: [${(binds||[]).join(',')}]`;
        var newError = new Error(errmsg);
        newError.state = error.state;
        throw newError;
    }  
}
var temptable_prefix, tablelist = [];
var INSERT_TEMP = function (query,parameters) {
   if (!temptable_prefix) {
    var curr_schema_stmt = 'SELECT CURRENT_SCHEMA();';
    var rs = snowflake.createStatement({
        sqlText: curr_schema_stmt,
        binds: []
    }).execute();
    var curr_schema = rs.next() && rs.getColumnValue(1);
   
    var sql_stmt = `select ifnull(try_to_number(SUBSTR(table_name, charindex('_', table_name)+1)), 0) as lasttemptable
        from information_schema.tables
        where table_type like '%TEMPORARY%' and table_schema = current_schema()
        order by lasttemptable
        desc limit 1;`;
    rs = snowflake.createStatement({
         sqlText : sql_stmt,
         binds : []
    });
    result = rs.execute();
     
    if (result.getRowCount() > 0) {
      temptable_prefix = result.next() && (curr_schema + '.TEMP_' + (result.getColumnValue(1) + 1));
    } else {
      temptable_prefix = curr_schema + '.TEMP_0';
    }
   }
    var fixBind = (arg) => arg == undefined ? null : arg instanceof Date ? arg.toISOString() : arg;
    parameters = parameters ? parameters.map(fixBind) : (parameters || []);
   //var tablename = temptable_prefix;
   //tablelist.push(temptable_prefix);
   var sql_stmt = `CREATE TEMP TABLE ${temptable_prefix} AS ${query}`;
   snowflake.execute({
      sqlText : sql_stmt,
      binds : parameters
   });
   return temptable_prefix;
};

var result = INSERT_TEMP(`
            SELECT
                  FirstName AS "FirstName"
                  ,LastName AS "LastName"
                  ,JobTitle AS "JobTitle"
                  ,BirthDate AS "BirthDate"
                  ,Gender AS "Gender"
                  ,Department AS "Department"
                  ,"Group Department" AS "Group Department"
             FROM ADVENTUREWORKS.HUMANRESOURCES.vPowerBIEmployee
        `);
return result;

$$;

/****** Data Load:  Table vPowerBIEmployee ******/
PUT file://.\vPowerBISales.csv @~/sales_stage;
COPY INTO vPowerBISales from @~/sales_stage file_format = (format_name = 'ADVENTUREWORKS_CSV');

/****** Data Load:  Table vPowerBISales ******/
PUT file://.\vPowerBIEmployee.csv @~/employee_stage;
COPY INTO vPowerBIEmployee from @~/employee_stage file_format = (format_name = 'ADVENTUREWORKS_CSV');