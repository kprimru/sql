USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[SUBHOST_CITY_EDIT] 
	@subhostcityid INT,
	@subhostid SMALLINT,
	@cityid SMALLINT,
	@marketareaid SMALLINT,
	@active BIT
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

		UPDATE dbo.SubhostCityTable
		SET 
			SC_ID_SUBHOST = @subhostid,
			SC_ID_CITY = @cityid, 
			SC_ID_MARKET_AREA = @marketareaid,
			SC_ACTIVE = @active
		WHERE SC_ID = @subhostcityid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
