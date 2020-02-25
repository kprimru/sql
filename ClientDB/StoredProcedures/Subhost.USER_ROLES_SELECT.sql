USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[USER_ROLES_SELECT]
	@SH_ID	UNIQUEIDENTIFIER,
	@LGN	NVARCHAR(128)
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

		DECLARE @XML XML
		
		DECLARE @R NVARCHAR(MAX)
		
		SELECT @R = ROLES
		FROM Subhost.Users
		WHERE ID_SUBHOST = @SH_ID AND NAME = @LGN

		SET @XML = CAST(@R AS XML)

		SELECT RL_NAME, RL_CAPTION, CONVERT(BIT, CASE WHEN RL IS NOT NULL THEN 1 ELSE 0 END) AS CHECKED
		FROM 
			Subhost.RolesView a
			LEFT OUTER JOIN
				(
					SELECT 
						c.value('(@name)', 'NVARCHAR(128)') AS RL
					FROM @XML.nodes('/root/role') a(c)
				) AS b ON a.RL_NAME = b.RL
		ORDER BY ORD
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
