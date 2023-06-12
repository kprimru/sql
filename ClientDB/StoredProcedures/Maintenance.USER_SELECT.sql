USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[USER_SELECT]
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


		SELECT [User], [DefaultChecked]
		FROM
		(
			SELECT [UPD_USER] AS [User]
			FROM [dbo].[ClientTable]

			UNION

			SELECT [EventLastUpdateUser]
			FROM [dbo].[EventTable]

			UNION

			SELECT [UPD_USER]
			FROM [dbo].[ClientContact]
		) AS H
		OUTER APPLY
		(
			SELECT
				[DefaultChecked] =
					Cast(
						CASE
							-- TODO: именованное множество?
							WHEN H.[User] IN ('Алексенко', 'Кравцова', 'Белова', 'Лавриненко') THEN 1
							ELSE 0
						END AS Bit)
		) AS M
		ORDER BY [User]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[USER_SELECT] TO rl_user_action_filter;
GO
