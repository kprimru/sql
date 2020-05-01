USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CALL_SELECT]
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
			CC_ID, CC_DATE, CC_PERSONAL, CC_NOTE,
			CONVERT(BIT, CASE
				WHEN CT_TRUST = 1 OR CT_MAKE IS NOT NULL THEN 1
				WHEN CT_TRUST = 0 AND CT_MAKE IS NULL THEN 0
				ELSE 1
			END) AS CT_TRUST_MARKER,
			CASE CT_TRUST
				WHEN 1 THEN 'Достоверен'
				WHEN 0 THEN
					CASE
						WHEN CT_MAKE IS NULL THEN 'Не достоверен'
						ELSE 'Не достоверен (исправлено)'
					END
				ELSE 'Не опрашивался'
			END AS CT_TRUST,
			STT_NAME, STT_RESULT, CS_NOTE,
			CT_MAKE_USER + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 104) + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 108) AS CT_MAKE_DATA,
			CC_USER
		FROM
			dbo.ClientCall
			LEFT OUTER JOIN dbo.ClientTrust ON CT_ID_CALL = CC_ID
			LEFT OUTER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
			LEFT OUTER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
		WHERE CC_ID_CLIENT = @CLIENT
		ORDER BY CC_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_CALL_SELECT] TO rl_client_call_r;
GO