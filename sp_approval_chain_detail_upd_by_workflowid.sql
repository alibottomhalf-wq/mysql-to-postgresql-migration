-- DROP PROCEDURE public.sp_approval_chain_detail_upd_by_workflowid(in int4, in int8, in bit, in int4, in int4, in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_approval_chain_detail_upd_by_workflowid(IN _approvalworkflowid integer, IN _assignieid bigint, IN _isrequired bit, IN _autoactiontype integer, IN _autoactiondays integer, IN _approvalstatus integer, OUT _processingresult character varying)
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

    IF EXISTS (
        SELECT 1 
        FROM approval_chain_detail 
        WHERE approvalworkflowid = _approvalworkflowid
    ) THEN 
        UPDATE approval_chain_detail 
        SET
            assignieid = _assignieid,
            isrequired = _isrequired,
            autoactiontype = _autoactiontype,
            autoactiondays = _autoactiondays,
            lastupdatedon = timezone('utc', now()),
            approvalstatus = _approvalstatus
        WHERE approvalworkflowid = _approvalworkflowid;
        
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
        'sp_approval_chain_detail_upd_by_workflowid'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
