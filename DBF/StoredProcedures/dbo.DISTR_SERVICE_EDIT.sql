USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	




/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[DISTR_SERVICE_EDIT] 
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





