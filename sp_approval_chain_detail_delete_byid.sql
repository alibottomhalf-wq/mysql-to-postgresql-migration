-- DROP PROCEDURE public.sp_approval_chain_detail_delete_byid(in int4, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_approval_chain_detail_delete_byid(IN _approvalchaindetailid integer, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _approvalworkflowid bigint;
BEGIN
    _approvalworkflowid := 0;
    
    SELECT approvalworkflowid 
    INTO _approvalworkflowid 
    FROM approval_chain_detail 
    WHERE approvalchaindetailid = _approvalchaindetailid;
    
    IF _approvalworkflowid IS NULL OR _approvalworkflowid = 0 THEN
        _processingresult := 'Record not found';
    ELSE
        DELETE FROM approval_chain_detail 
        WHERE approvalchaindetailid = _approvalchaindetailid;
        
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
        'sp_approval_chain_detail_delete_byid'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$
;
