USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [KGS].[MEMO_CLAIM_SELECT]
	@TP		TINYINT,
	@CLIENT	NVARCHAR(256),
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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
			a.ID, TP, CASE TP WHEN 1 THEN 'Коммерч' WHEN 2 THEN 'Контракт' ELSE '???' END AS TP_STR, 
			DATE, ID_CLIENT, CL_NAME, b.SHORT AS VD_NAME, c.TS_SHORT AS TRADESITE, DATE_LIMIT
		FROM 
			KGS.MemoClaim a
			INNER JOIN dbo.Vendor b ON a.ID_VENDOR = b.ID
			INNER JOIN Purchase.Tradesite c ON ID_TRADESITE = c.TS_ID
		WHERE STATUS = 1
			AND (TP = @TP OR @TP IS NULL)
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE <= @END OR @END IS NULL)
			AND (CL_NAME LIKE @CLIENT OR @CLIENT IS NULL)
		ORDER BY DATE DESC 
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
