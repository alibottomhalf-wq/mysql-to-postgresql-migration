-- DROP PROCEDURE public.sp_approval_work_flow_insupd(in int4, in varchar, in varchar, in int4, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_approval_work_flow_insupd(IN _approvalworkflowid integer, IN _title character varying, IN _titledescription character varying, IN _status integer, IN _adminid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN
    _processingresult := '';

    IF NOT EXISTS (
        SELECT 1 
        FROM approval_work_flow 
        WHERE approvalworkflowid = _approvalworkflowid
    ) THEN
        SELECT COALESCE(MAX(approvalworkflowid), 0) + 1 
        INTO _approvalworkflowid 
        FROM approval_work_flow;

        INSERT INTO approval_work_flow (
            approvalworkflowid,
            title,
            titledescription,
            status,
            createdby,
            createdon,
            updatedby,
            updatedon
        ) VALUES (
            _approvalworkflowid,
            _title,
            _titledescription,
            _status,
            _adminid,
            timezone('utc', now()),
            NULL,
            NULL
        );
        
        _processingresult := _approvalworkflowid::varchar;
    ELSE
        UPDATE approval_work_flow 
        SET
            title = _title,
            titledescription = _titledescription,
            status = _status,
            updatedby = _adminid,
            updatedon = timezone('utc', now())
        WHERE approvalworkflowid = _approvalworkflowid;
        
        _processingresult := _approvalworkflowid::varchar;
    END IF;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_approval_work_flow_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
