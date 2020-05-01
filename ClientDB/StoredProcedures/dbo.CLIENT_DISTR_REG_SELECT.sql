USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_REG_SELECT]
	@ID	INT
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
			ID, SystemOrder, DistrStr, NULL AS SystemTypeName, DistrTypeName,
			DS_NAME, DS_REG, DS_INDEX
		FROM
			(
				SELECT ID, SystemOrder, DistrStr, DistrTypeName, DS_NAME, DS_REG, DS_INDEX
				FROM Reg.RegNodeSearchView		r WITH(NOEXPAND)
				WHERE COMPLECT = (SELECT COMPLECT FROM Reg.RegNodeSearchView WITH(NOEXPAND) WHERE ID = @ID)

				UNION

				SELECT ID, SystemOrder, DistrStr, DistrTypeName, DS_NAME, DS_REG, DS_INDEX
				FROM Reg.RegNodeSearchView		r WITH(NOEXPAND)
				WHERE ID = @ID
			) AS o_O
		ORDER BY DS_REG, SystemOrder, DistrStr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_REG_SELECT] TO rl_tech_reg;
GO