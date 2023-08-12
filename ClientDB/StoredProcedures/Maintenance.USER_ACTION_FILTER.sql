USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USER_ACTION_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USER_ACTION_FILTER]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[USER_ACTION_FILTER]
	@Users		VarChar(Max),
	@DateFrom	SmallDateTime,
	@DateTo		SmallDateTime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE	@Detail Table
	(
		[User]	VarChar(128),
		[Date]	SmallDateTime,
		[Type]	VarChar(128),
		[Count]	Int,
		PRIMARY KEY CLUSTERED([User], [Date], [Type])
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @DateTo = DateAdd(Day, 1, @DateTo);

		INSERT INTO @Detail
		SELECT H.*
		FROM
		(
			SELECT [UPD_USER] AS [User], Cast([ClientLast] AS Date) AS [Date], 'Клиент' AS [Type], Count(DISTINCT [ID_MASTER]) AS [Count]
			FROM [dbo].[ClientTable]
			WHERE [ClientLast] >= @DateFrom
				AND [ClientLast] < @DateTo
			GROUP BY [UPD_USER], Cast([ClientLast] AS Date)

			UNION ALL

			SELECT [EventLastUpdateUser], Cast([EventLastUpdate] AS Date), 'История посещений', Count(DISTINCT [MasterID])
			FROM [dbo].[EventTable]
			WHERE [EventLastUpdate] >= @DateFrom
				AND [EventLastUpdate] < @DateTo
			GROUP BY [EventLastUpdateUser], Cast([EventLastUpdate] AS Date)

			UNION ALL

			SELECT [UPD_USER], Cast([UPD_DATE] AS Date), 'Контакты РГ' AS [Type], Count(DISTINCT IsNull(ID_MASTER, ID))
			FROM [dbo].[ClientContact]
			WHERE [UPD_DATE] >= @DateFrom
				AND [UPD_DATE] < @DateTo
			GROUP BY [UPD_USER], Cast([UPD_DATE] AS Date)
		) AS H
		INNER JOIN String_Split(@Users, ',') AS U ON U.[value] = H.[User]
		ORDER BY 1, 2

		SELECT
			[User], [Date], [ClientCount], [EventCount], [ContactCount]
		FROM
		(
			SELECT DISTINCT [User]
			FROM @Detail
		) AS U
		CROSS JOIN
		(
			SELECT DISTINCT [Date]
			FROM @Detail
		) AS D
		OUTER APPLY
		(
			SELECT [ClientCount] =  h.[Count]
			FROM @Detail AS H
			WHERE H.[User] = u.[User]
				AND h.[Date] = d.[Date]
				AND h.[Type] = 'Клиент'
		) AS CLIENT
		OUTER APPLY
		(
			SELECT [ContactCount] =  h.[Count]
			FROM @Detail AS H
			WHERE H.[User] = u.[User]
				AND h.[Date] = d.[Date]
				AND h.[Type] = 'Контакты РГ'
		) AS CONTACT
		OUTER APPLY
		(
			SELECT [EventCount] = h.[Count]
			FROM @Detail AS H
			WHERE H.[User] = u.[User]
				AND h.[Date] = d.[Date]
				AND h.[Type] = 'История посещений'
		) AS EVNT
		ORDER BY [Date] DESC, [User];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[USER_ACTION_FILTER] TO rl_user_action_filter;
GO
