USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_WHITELIST_SYSTEMS]
WITH EXECUTE AS OWNER
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

		SELECT R.SystemBaseName AS SystemName, R.DistrNumber, R.CompNumber
		FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
		LEFT JOIN dbo.BLACK_LIST_REG B ON (B.DISTR=R.DistrNumber)
										AND(B.COMP=R.CompNumber)
										AND(B.ID_SYS=R.SystemID)
										AND(B.[P_DELETE]=0)
		WHERE B.ID IS NULL
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END