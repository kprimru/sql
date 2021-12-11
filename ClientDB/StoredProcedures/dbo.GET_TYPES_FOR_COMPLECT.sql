USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_TYPES_FOR_COMPLECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_TYPES_FOR_COMPLECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[GET_TYPES_FOR_COMPLECT]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT DistrTypeID, DistrTypeName, DistrTypeName AS DistrTypeShortName
		FROM dbo.DistrTypeTable
		WHERE DistrTypeName IN ('ëîê', 'ñåòü', 'ÎÂÊ-Ô','ÎÂÌ-Ô(1;2)')
		ORDER BY DistrTypeOrder

		--SELECT NT_SHORT, NT_ID, [NT_VMI_SHORT]
		--FROM din.NetType
		--WHERE
		--     [NT_TECH] IN (0,1,10,11)
		--	  AND (NT_SHORT IN ('ëîê', 'ÎÂÊ-Ô','ÎÂÌ-Ô (1;2)'))
		--  ORDER BY NT_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_TYPES_FOR_COMPLECT] TO public;
GO
