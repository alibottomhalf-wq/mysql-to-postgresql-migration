-- DROP PROCEDURE public.sp_approval_chain_detail_insupd(in int4, in int4, in int8, in bit, in int4, in int4, in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_approval_chain_detail_insupd(IN _approvalchaindetailid integer, IN _approvalworkflowid integer, IN _assignieid bigint, IN _isrequired bit, IN _autoactiontype integer, IN _autoactiondays integer, IN _approvalstatus integer, OUT _processingresult character varying)
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
        FROM approval_chain_detail 
        WHERE approvalchaindetailid = _approvalchaindetailid
    ) THEN
        SELECT COALESCE(MAX(approvalchaindetailid), 0) + 1 
        INTO _approvalchaindetailid 
        FROM approval_chain_detail;

        INSERT INTO approval_chain_detail (
            approvalchaindetailid,
            approvalworkflowid,
            assignieid,
            isrequired,
            autoactiontype,
            autoactiondays,
            createdon,
            approvalstatus
        ) VALUES (
            _approvalchaindetailid,
            _approvalworkflowid,
            _assignieid,
            _isrequired,
            _autoactiontype,
            _autoactiondays,
            timezone('utc', now()),
            _approvalstatus
        );
        
        _processingresult := 'inserted';
    ELSE
        UPDATE approval_chain_detail 
        SET
            approvalworkflowid = _approvalworkflowid,
            assignieid = _assignieid,
            isrequired = _isrequired,
            autoactiontype = _autoactiontype,
            autoactiondays = _autoactiondays, 
            lastupdatedon = timezone('utc', now()),
            approvalstatus = _approvalstatus
        WHERE approvalchaindetailid = _approvalchaindetailid;
        
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
        'sp_approval_chain_detail_insupd'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
