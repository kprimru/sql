USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_SERVICE_EDIT]
	@dsid SMALLINT,
	@dsname VARCHAR(100),
	@statusid SMALLINT,
	@subhost BIT,
	@dsreport BIT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.DistrServiceStatusTable
	SET DSS_NAME = @dsname,
		DSS_ID_STATUS = @statusid,
		DSS_SUBHOST = @subhost,
		DSS_REPORT = @dsreport,
		DSS_ACTIVE = @active
	WHERE DSS_ID = @dsid

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON [dbo].[DISTR_SERVICE_EDIT] TO rl_distr_service_w;
GO