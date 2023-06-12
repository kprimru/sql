USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[GET_WHITELIST_SYSTEMS_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[GET_WHITELIST_SYSTEMS_FILTER]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[GET_WHITELIST_SYSTEMS_FILTER]
	@COMMENT	varchar(128)
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
		WHERE (B.ID IS NULL)AND((CHARINDEX(@COMMENT, R.COMMENT)>0)AND(CHARINDEX(@COMMENT, R.COMMENT)<3))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[GET_WHITELIST_SYSTEMS_FILTER] TO BL_ADMIN;
GRANT EXECUTE ON [dbo].[GET_WHITELIST_SYSTEMS_FILTER] TO BL_PARAM;
GRANT EXECUTE ON [dbo].[GET_WHITELIST_SYSTEMS_FILTER] TO BL_RGT;
GO
