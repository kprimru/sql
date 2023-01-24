USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientStudyClaim@Create?Auto]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ClientStudyClaim@Create?Auto]  AS SELECT 1')
GO
CREATE   PROCEDURE [dbo].[ClientStudyClaim@Create?Auto]
	@Client_Id		Int,
	@Reason			VarChar(256),
	@CreateClaim	Bit = 1,
	@FillPersonal	Bit = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@AvailableReasons	VarChar(512);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT;

	BEGIN TRY

		IF (SELECT [Maintenance].[GlobalClientAutoClaim]()) = 1 BEGIN
			IF @CreateClaim = 1 BEGIN
				SELECT @AvailableReasons = [Maintenance].[GlobalClientAutoClaimTypes]();

				INSERT INTO [dbo].[ClientStudyClaim]([ID_CLIENT], [DATE], [NOTE], [REPEAT], [UPD_USER])
				SELECT @Client_Id, [dbo].[DateOf](GetDate()), @Reason, 0, 'Автомат'
				WHERE NOT EXISTS
					(
						SELECT *
						FROM [dbo].[ClientStudyClaim] AS C
						WHERE	C.[ID_CLIENT] = @Client_Id
							AND C.[ID_MASTER] IS NULL
							AND C.[UPD_USER] = 'Автомат'
					)
					AND EXISTS
					(
						SELECT *
						FROM String_Split(@AvailableReasons, ',') AS R
						WHERE R.[value] = @Reason
					);
			END;

			IF @FillPersonal = 1 BEGIN
				IF EXISTS
					(
						SELECT *
						FROM [dbo].[ClientStudyClaim] AS C
						WHERE	C.[ID_CLIENT] = @Client_Id
							AND C.[ID_MASTER] IS NULL
							AND C.[UPD_USER] = 'Автомат'
							AND NOT EXISTS
								(
									SELECT *
									FROM [dbo].[ClientStudyClaimPeople] AS P
									WHERE C.[ID] = P.[ID_CLAIM]
								)
					)
				BEGIN
					INSERT INTO [dbo].[ClientStudyClaimPeople]([ID_CLAIM], [SURNAME], [NAME], [PATRON], [POSITION], [PHONE], [GR_COUNT], [NOTE])
					SELECT
						(
							SELECT TOP (1) C.[ID]
							FROM [dbo].[ClientStudyClaim] AS C
							WHERE	C.[ID_CLIENT] = @Client_Id
								AND C.[UPD_USER] = 'Автомат'
								AND NOT EXISTS
									(
										SELECT *
										FROM [dbo].[ClientStudyClaimPeople] AS P
										WHERE C.[ID] = P.[ID_CLAIM]
									)
						),
						CP.[CP_SURNAME], CP.[CP_NAME], CP.[CP_PATRON], CP.[CP_POS], CP.[CP_PHONE], NULL, ''
					FROM
					(
						SELECT CP.[CP_SURNAME], CP.[CP_NAME], CP.[CP_PATRON], CP.[CP_POS], CP.[CP_PHONE]
						FROM [dbo].[ClientPersonalResView] AS CP WITH(NOEXPAND)
						WHERE CP.[CP_ID_CLIENT] = @Client_Id

						UNION

						SELECT CP.[CP_SURNAME], CP.[CP_NAME], CP.[CP_PATRON], CP.[CP_POS], CP.[CP_PHONE]
						FROM [dbo].[ClientPersonalBuhView] AS CP WITH(NOEXPAND)
						WHERE CP.[CP_ID_CLIENT] = @Client_Id
					) AS CP;
				END
			END;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
