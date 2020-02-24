USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_KIND_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT K.Id, K.Name, K.SortIndex, Checked = CAST(CASE WHEN C.SetItem IS NOT NULL THEN 1 ELSE 0 END AS Bit)
		FROM dbo.ClientKind K
		LEFT JOIN dbo.NamedSetItemsSelect('dbo.ClientKind', 'DefaultChecked') C ON K.Id = Cast(C.SetItem AS SmallInt)
		WHERE	@FILTER IS NULL
			OR	Name LIKE @FILTER
		ORDER BY SortIndex
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
