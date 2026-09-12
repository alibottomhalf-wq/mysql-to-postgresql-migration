-- DROP PROCEDURE public.sp_biometric_daily_logs_ins(in int8, in timestamp, in varchar, in varchar, in varchar, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_biometric_daily_logs_ins(IN _employeeuid bigint, IN _logdatetime timestamp without time zone, IN _punchtype character varying, IN _deviceid character varying, IN _location character varying, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    INSERT INTO biometric_daily_logs (
        employeeuid,
        logdatetime,
        punchtype,
        deviceid,
        location,
        createdon
    ) VALUES (
        _employeeuid,
        _logdatetime,
        _punchtype,
        _deviceid,
        _location,
        timezone('utc', now())
    );
 
    _processingresult := 'inserted';

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_biometric_daily_logs_ins'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
