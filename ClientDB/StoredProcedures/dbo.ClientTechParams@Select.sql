USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientTechParams@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ClientTechParams@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ClientTechParams@Select]
    @Client_Id		Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@Child_Id		Int;

	DECLARE @ClientParams Table
		(
			[Name]		VarChar(256),
			[SortIndex]	TinyInt,
			[Value]		VarChar(256),
			PRIMARY KEY CLUSTERED ([Name])
		)

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

		-- находим первую редакция картолчки
		SET @Child_Id =
			(
				SELECT TOP (1) C.[ClientID]
				FROM
				(
					SELECT C.[ClientID], C.[ClientLast]
					FROM dbo.ClientTable AS C
					WHERE ClientID = @Client_Id
					UNION ALL
					SELECT C.[ClientID], C.[ClientLast]
					FROM dbo.ClientTable AS C
					WHERE ID_MASTER = @Client_Id
				) AS C
				ORDER BY C.[ClientLast]
			);

		INSERT INTO @ClientParams([Name], [Value], [SortIndex])
		SELECT P.[Name], P.[Value], P.[SortIndex]
		FROM dbo.ClientTable AS C
		CROSS APPLY
		(
			SELECT
				[Name] = 'Дата-время создания',
				[Value] = Convert(VarChar(20), C.[ClientLast], 104) + ' ' + Convert(VarChar(20), C.[ClientLast], 108),
				[SortIndex] = 1
			---
			UNION ALL
			---
			SELECT
				[Name] = 'Создал пользователь',
				[Value] = C.[UPD_USER],
				[SortIndex] = 2
		) AS P
		WHERE ClientID = @Child_Id;

		SELECT
			P.[Name],
			P.[Value]
		FROM @ClientParams AS P
		ORDER BY
			P.[SortIndex];

    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ClientTechParams@Select] TO rl_client_tech_params;
GO
