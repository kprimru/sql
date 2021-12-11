USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIVAL_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIVAL_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_PRINT]
	@CL_ID	INT
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
			CR_ID, CR_DATE, RivalTypeName, CR_COMPLETE,
			CR_CONTROL, CR_CONTROL_DATE, CR_CONDITION,

			CRR_DATE, CRR_COMMENT
		FROM
			dbo.ClientRival
			LEFT OUTER JOIN dbo.RivalTypeTable ON RivalTypeID = CR_ID_TYPE
			LEFT OUTER JOIN dbo.ClientRivalReaction ON CR_ID = CRR_ID_RIVAL
		WHERE CR_ACTIVE = 1 AND ISNULL(CRR_ACTIVE, 1) = 1
			AND CL_ID = @CL_ID
		ORDER BY CR_DATE DESC, CR_ID, CRR_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_PRINT] TO rl_client_rival_p;
GO
