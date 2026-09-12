-- DROP PROCEDURE public.sp_allocatedassets_upd(in int8, in int4, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_allocatedassets_upd(IN _employeeassetsallocationid bigint, IN _status integer, IN _handledby bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM employee_assets_allocation 
        WHERE employeeassetsallocationid = _employeeassetsallocationid
    ) THEN
        _processingresult := 'Employee asset allocation detail not found';
        RAISE EXCEPTION '%', _processingresult;
    END IF;

    UPDATE employee_assets_allocation 
    SET 
        returnstatus = _status,
        returnedon = timezone('utc', now()),
        returnedhandledby = _handledby
    WHERE employeeassetsallocationid = _employeeassetsallocationid;

    _processingresult := 'updated';

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_allocatedassets_upd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
