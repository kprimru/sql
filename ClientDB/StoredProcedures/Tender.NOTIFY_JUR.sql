USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[NOTIFY_JUR]
	@TENDER	UNIQUEIDENTIFIER
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
			'������ ����!' + CHAR(10) + CLIENT + ' �������� ' + TENDER_TYPE + ' �� ' + SUBJECT + '.' + CHAR(10) + CHAR(10) +
			'������ ���������� �� ' + ISNULL(CONVERT(NVARCHAR(32), CLAIM_FINISH, 104) + ' �.', '')
					AS MAIL_BODY
		FROM
			(
				SELECT
					b.CLIENT,
					d.PK_NAME AS [TENDER_TYPE], c.URL,
					c.SUBJECT,
					CLAIM_FINISH,
					c.DATE
				FROM
					Tender.Tender b
					INNER JOIN Tender.Placement c ON b.ID = c.ID_TENDER
					INNER JOIN Purchase.PurchaseKind d ON c.ID_TYPE = d.PK_ID
				WHERE b.ID = @TENDER
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[NOTIFY_JUR] TO rl_tender_r;
GO
