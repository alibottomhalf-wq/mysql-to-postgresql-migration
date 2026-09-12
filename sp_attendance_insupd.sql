-- DROP PROCEDURE public.sp_attendance_insupd(in int8, in int8, in int4, in jsonb, in int4, in int4, in int4, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in int8, in varchar, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_attendance_insupd(IN _attendanceid bigint, IN _employeeid bigint, IN _usertypeid integer, IN _attendancedetail jsonb, IN _totaldays integer, IN _totalweekdays integer, IN _dayspending integer, IN _totalburnedminutes integer, IN _foryear integer, IN _formonth integer, IN _pendingrequestcount integer, IN _employeename character varying, IN _email character varying, IN _mobile character varying, IN _reportingmanagerid bigint, IN _managername character varying, IN _userid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _target_id bigint;
BEGIN
    _processingresult := '';

    IF NOT EXISTS (SELECT 1 FROM attendance WHERE attendanceid = _attendanceid) THEN
        SELECT COALESCE(MAX(attendanceid), 0) + 1 
        INTO _target_id 
        FROM attendance;

        INSERT INTO attendance (
            attendanceid,
            employeeid,
            usertypeid,
            attendancedetail,
            totaldays,
            totalweekdays,
            dayspending,
            totalburnedminutes,
            foryear,
            formonth,
            createdon,
            updatedon,
            createdby,
            updatedby,
            pendingrequestcount,
            employeename,
            email,
            mobile,
            reportingmanagerid,
            managername
        ) VALUES (
            _target_id,
            _employeeid,
            _usertypeid,
            _attendancedetail,
            _totaldays,
            _totalweekdays,
            _dayspending,
            _totalburnedminutes,
            _foryear,
            _formonth,
            timezone('utc', now()),
            timezone('utc', now()),
            _userid,
            NULL,
            _pendingrequestcount,
            _employeename,
            _email,
            _mobile,
            _reportingmanagerid,
            _managername
        );
        
        _processingresult := _target_id::varchar;
    ELSE
        UPDATE attendance a 
        SET
            employeeid = _employeeid,
            usertypeid = _usertypeid,
            attendancedetail = _attendancedetail,
            totaldays = _totaldays,
            totalweekdays = _totalweekdays,
            dayspending = _dayspending,
            totalburnedminutes = _totalburnedminutes,
            formonth = _formonth,
            foryear = _foryear,
            pendingrequestcount = COALESCE(a.pendingrequestcount, 0) + COALESCE(_pendingrequestcount, 0),
            updatedon = timezone('utc', now()),
            updatedby = _userid,
            employeename = _employeename,
            email = _email,
            mobile = _mobile,
            reportingmanagerid = _reportingmanagerid,
            managername = _managername
        WHERE attendanceid = _attendanceid;
        
        _processingresult := _attendanceid::varchar;
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_attendance_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
