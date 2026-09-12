-- DROP PROCEDURE public.sp_attendance_update_request(in int8, in int8, in varchar, in varchar, in int4, in jsonb, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_attendance_update_request(IN _attendanceid bigint, IN _reviewerid bigint, IN _revieweremail character varying, IN _reviewername character varying, IN _attendancestatus integer, IN _comments jsonb, IN _userid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    _processingresult := 'Record not found';

    IF EXISTS (SELECT 1 FROM daily_attendance WHERE attendanceid = _attendanceid) THEN
        UPDATE daily_attendance 
        SET
            reviewerid = _reviewerid,
            revieweremail = _revieweremail,
            reviewername = _reviewername,
            attendancestatus = _attendancestatus,
            comments = _comments,
            updatedby = _userid,
            updatedon = timezone('utc', now())
        WHERE attendanceid = _attendanceid; 
        
        _processingresult := 'updated';
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_attendance_update_request'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
