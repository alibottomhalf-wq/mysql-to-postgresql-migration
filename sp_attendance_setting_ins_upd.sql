-- DROP PROCEDURE public.sp_attendance_setting_ins_upd(in int4, in bit, in int4, in int4, in int4, in int4, in int4, in bit, in int4, in bit, in int4, in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_attendance_setting_ins_upd(IN _attendancesettingid integer, IN _attendancetype bit, IN _attendanceviewlimit integer, IN _attendancesubmissionlimit integer, IN _attendancemode integer, IN _backdatelimittoapply integer, IN _backweeklimittoapply integer, IN _isautoapprovalenable bit, IN _autoapproveafterdays integer, IN _approvalworkflowtype bit, IN _approvalworkflowid integer, IN _minworkdaysrequired integer, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _target_id integer;
BEGIN
    _processingresult := '';

    IF NOT EXISTS (
        SELECT 1 
        FROM attendance_setting 
        WHERE attendancesettingid = _attendancesettingid
    ) THEN
        SELECT COALESCE(MAX(attendancesettingid), 0) + 1 
        INTO _target_id 
        FROM attendance_setting;

        INSERT INTO attendance_setting (
            attendancesettingid,
            attendancetype,
            attendanceviewlimit,
            attendancesubmissionlimit,
            attendancemode,
            backdatelimittoapply,
            backweeklimittoapply,
            isautoapprovalenable,
            autoapproveafterdays,
            approvalworkflowtype,
            approvalworkflowid,
            minworkdaysrequired
        ) VALUES (
            _target_id,
            _attendancetype,
            _attendanceviewlimit,
            _attendancesubmissionlimit,
            _attendancemode,
            _backdatelimittoapply,
            _backweeklimittoapply,
            _isautoapprovalenable,
            _autoapproveafterdays,
            _approvalworkflowtype,
            _approvalworkflowid,
            _minworkdaysrequired
        );

        _processingresult := 'inserted';
    ELSE
        UPDATE attendance_setting 
        SET
            attendancetype = _attendancetype,
            attendanceviewlimit = _attendanceviewlimit,
            attendancesubmissionlimit = _attendancesubmissionlimit,
            attendancemode = _attendancemode,
            backdatelimittoapply = _backdatelimittoapply,
            backweeklimittoapply = _backweeklimittoapply,
            isautoapprovalenable = _isautoapprovalenable,
            autoapproveafterdays = _autoapproveafterdays,
            approvalworkflowtype = _approvalworkflowtype,
            approvalworkflowid = _approvalworkflowid,
            minworkdaysrequired = _minworkdaysrequired
        WHERE attendancesettingid = _attendancesettingid;

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
        'sp_attendance_setting_ins_upd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
