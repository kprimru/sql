USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Reg].[REG_NODE_COMPLECT]
	@COMPLECT	VARCHAR(50)
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
			DistrStr, SST_SHORT, NT_SHORT, RegisterDate, DS_INDEX, z.Comment, SubhostName, HostID, DistrNumber, CompNumber,
			CONVERT(BIT, CASE WHEN DS_REG = 0 AND t.ID IS NOT NULL THEN 1 ELSE 0 END) AS BLACK
		FROM
			Reg.RegNodeSearchView z WITH(NOEXPAND)
			LEFT OUTER JOIN dbo.BLACK_LIST_REG t ON t.DISTR = z.DistrNumber AND z.CompNumber = t.COMP AND t.ID_SYS = z.SystemID AND P_DELETE = 0
		WHERE Complect = @COMPLECT
		ORDER BY SystemOrder, DistrNumber, CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[REG_NODE_COMPLECT] TO rl_reg_node_search;
GO