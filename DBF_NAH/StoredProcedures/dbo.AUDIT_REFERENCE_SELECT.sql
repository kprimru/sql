USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[AUDIT_REFERENCE_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT REF_NAME, REF_ERROR
	FROM dbo.AuditReferenceView
	ORDER BY REF_NAME
END


GO
GRANT EXECUTE ON [dbo].[AUDIT_REFERENCE_SELECT] TO rl_audit_ref;
GO