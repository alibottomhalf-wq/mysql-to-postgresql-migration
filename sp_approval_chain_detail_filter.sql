CREATE OR REPLACE PROCEDURE public.sp_approval_chain_detail_filter(
    _searchstring character varying,
    INOUT _cursor refcursor DEFAULT 'ref_result'
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
    _selectquery TEXT;
    _condition TEXT;
BEGIN
    _condition := COALESCE(NULLIF(TRIM(_searchstring), ''), '1=1');

    _selectquery := '
        SELECT 			
            f.title,
            f.titledescription,
            f.status,	
            w.approvalchaindetailid,
            w.approvalworkflowid,
            w.approverid,
            w.sequence,
            w.createdon,
            w.createdby
        FROM approval_chain_detail w
        INNER JOIN approval_work_flow f ON w.approvalworkflowid = f.approvalworkflowid
        WHERE ' || _condition;
 
    OPEN _cursor FOR EXECUTE _selectquery;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(
        _message::text, 
        ''::text, 
        'sp_approval_chain_detail_filter'::varchar, 
        B'1', 
        B'0', 
        _result
    );
END;
$procedure$;
