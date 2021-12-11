USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[TENDER_DEFAULT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[TENDER_DEFAULT]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[TENDER_DEFAULT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			ClientFullName, ContractBegin, ContractEnd,
			SURNAME, NAME, PATRON, POSITION, PHONE, EMAIL, ID_LAW, ID_STATUS
		FROM
			(
				SELECT ClientFulLName
				FROM dbo.ClientTable
				WHERE ClientID = @CLIENT
			) AS a
			OUTER APPLY
			(
				SELECT TOP 1 ContractBegin, ContractEnd
				FROM dbo.ContractTable
				WHERE ClientID = @CLIENT
					AND GETDATE() BETWEEN ContractBegin AND ContractEnd
				ORDER BY ContractEnd DESC
			) AS b
			OUTER APPLY
			(
				SELECT TOP 1 SURNAME, NAME, PATRON, POSITION, PHONE, EMAIL, ID_LAW
				FROM Tender.Tender
				WHERE ID_CLIENT = @CLIENT
					AND STATUS = 1
				ORDER BY INFO_DATE DESC
			) AS c
			OUTER APPLY
			(
				SELECT TOP 1 ID AS ID_STATUS
				FROM Tender.Status
				WHERE PSEDO = 'PLAN'
			) AS d

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[TENDER_DEFAULT] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[TENDER_DEFAULT] TO rl_tender_u;
GO
