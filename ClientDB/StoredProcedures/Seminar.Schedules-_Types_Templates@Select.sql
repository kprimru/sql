USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Schedules->Types_Templates@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Schedules->Types_Templates@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[Schedules->Types_Templates@Select]
    @FILTER     VarChar(512) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Templates Table
    (
        [Id]            SmallInt    Identity(1,1)   NOT NULL,
        [Parent_Id]     SmallInt                        NULL,
        [Type_Id]       SmallInt                    NOT NULL,
        [Template_Id]   SmallInt                    NOT NULL,
        [Date]          SmallDateTime               NOT NULL,
        PRIMARY KEY CLUSTERED([Id])
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Templates([Type_Id], [Template_Id], [Date])
        SELECT [Type_Id], [Template_Id], Max([Date])
        FROM [Seminar].[Schedules->Types:Templates]
        GROUP BY [Type_Id], [Template_Id]
        ORDER BY [Type_Id], [Template_Id];

        INSERT INTO @Templates([Parent_Id], [Type_Id], [Template_Id], [Date])
        SELECT I.[Id], T.[Type_Id], T.[Template_Id], T.[Date]
        FROM [Seminar].[Schedules->Types:Templates] AS T
        INNER JOIN @Templates                       AS I ON     T.[Type_Id] = I.[Type_Id]
                                                            AND T.[Template_Id] = I.[Template_Id]
                                                            AND T.[Date] != I.[Date]
        ORDER BY T.[Type_Id], T.[Template_Id], T.[Date] DESC;

        SELECT I.*, T.[Data]
        FROM @Templates AS I
        INNER JOIN [Seminar].[Schedules->Types:Templates] AS T ON   T.[Type_Id] = I.[Type_Id]
                                                                AND T.[Template_Id] = I.[Template_Id]
                                                                AND T.[Date] = I.[Date]
        ORDER BY I.[Id];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[Schedules->Types_Templates@Select] TO rl_seminar_admin;
GO
