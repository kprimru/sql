USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLAIM_SELECT]
	@BEGIN	SMALLDATETIME		= NULL,
	@END	SMALLDATETIME		= NULL,
	@AUTHOR	UNIQUEIDENTIFIER	= NULL,
	@STATUS	NVARCHAR(MAX)		= NULL,
	@CLIENT	NVARCHAR(512)		= NULL,
	@SYSTEM	UNIQUEIDENTIFIER	= NULL,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RowCount	Int = 500;

	DECLARE @Ids Table
	(
		[Id] UniqueIdentifier NOT NULL PRIMARY KEY CLUSTERED
	);

	DECLARE @IdByFilterType Table
	(
		[Id]		UniqueIdentifier	NOT NULL,
		[Type]		TinyInt				NOT NULL
		Primary Key Clustered([Id], [Type])
	);

	DECLARE @UsedFilterTypes Table
	(
		[Type]		TinyInt	NOT NULL
		Primary Key Clustered([Type])
	);


	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		IF @BEGIN IS NULL AND @END IS NULL AND @AUTHOR IS NULL AND @STATUS IS NULL AND @CLIENT IS NULL AND @SYSTEM IS NULL BEGIN
			INSERT INTO @Ids
			SELECT TOP (@RowCount) D.[ID]
			FROM [Claim].[Document]			AS D
			INNER JOIN [Security].[Users]	AS U ON U.[ID] = D.[ID_AUTHOR]
			WHERE D.[STATUS] = 1
				AND (
						-- просмотр только своих
						(U.[NAME] = ORIGINAL_LOGIN() AND IS_MEMBER('rl_claim_r') = 1)
						-- просмотр всех
						OR (IS_MEMBER('rl_claim_all') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
						OR (IS_MEMBER('rl_claim_department') = 1 AND U.[ID_DEPARTMENT] = (SELECT [ID_DEPARTMENT] FROM [Security].[Users] WHERE NAME = ORIGINAL_LOGIN()))
					)
			ORDER BY
				D.[DATE] DESC;
		END ELSE BEGIN
			INSERT INTO @IdByFilterType
			SELECT D.[ID], 0
			FROM [Claim].[Document] AS D
			INNER JOIN [Security].[Users]	AS U ON U.[ID] = D.[ID_AUTHOR]
			WHERE D.[STATUS] = 1
				AND (
						-- просмотр только своих
						(U.[NAME] = ORIGINAL_LOGIN() AND IS_MEMBER('rl_claim_r') = 1)
						-- просмотр всех
						OR (IS_MEMBER('rl_claim_all') = 1 OR IS_SRVROLEMEMBER('sysadmin') = 1)
						OR (IS_MEMBER('rl_claim_department') = 1 AND U.[ID_DEPARTMENT] = (SELECT [ID_DEPARTMENT] FROM [Security].[Users] WHERE NAME = ORIGINAL_LOGIN()))
					);

			IF @BEGIN IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 1
				FROM [Claim].[Document] AS D
				WHERE D.[STATUS] = 1
					AND D.[DATE_S] >= @BEGIN;

				INSERT INTO @UsedFilterTypes
				SELECT 1;
			END;

			IF @END IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 2
				FROM [Claim].[Document] AS D
				WHERE D.[STATUS] = 1
					AND DATE_S <= @END;

				INSERT INTO @UsedFilterTypes
				SELECT 2;
			END;

			IF @AUTHOR IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 3
				FROM [Claim].[Document] AS D
				WHERE D.[STATUS] = 1
					AND ID_AUTHOR = @AUTHOR;

				INSERT INTO @UsedFilterTypes
				SELECT 3;
			END;

			IF @STATUS IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 4
				FROM [Claim].[Document] AS D
				CROSS APPLY
				(
					SELECT TOP 1 S.[STATUS]
					FROM [Claim].[DocumentStatus] AS S
					WHERE S.[ID_DOCUMENT] = D.[ID]
					ORDER BY S.[DATE] DESC
				) AS S
				INNER JOIN [Common].[TableIntFromXML](@STATUS) AS FS ON FS.[ID] = S.[STATUS]
				WHERE D.[STATUS] = 1;

				INSERT INTO @UsedFilterTypes
				SELECT 4;
			END;

			IF @CLIENT IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 5
				FROM [Claim].[Document] AS D
				WHERE D.[STATUS] = 1
					AND CL_NAME LIKE @CLIENT;

				INSERT INTO @UsedFilterTypes
				SELECT 5;
			END;

			IF @SYSTEM IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT D.[ID], 6
				FROM [Claim].[Document] AS D
				WHERE D.[STATUS] = 1
					AND EXISTS
						(
							SELECT *
							FROM [Claim].[DocumentDetail] AS DD
							WHERE DD.[ID_DOCUMENT] = D.[ID]
								AND
									(
											DD.[ID_SYSTEM] = @SYSTEM
										OR	DD.[ID_NEW_SYSTEM] = @SYSTEM
									)
						)

				INSERT INTO @UsedFilterTypes
				SELECT 6;
			END;

			INSERT @IDs ([Id])
			SELECT
				[Id] = D.[Id]
			FROM
			(
				SELECT
					[Id] = D.[Id]
				FROM
				(
					SELECT DISTINCT [Id] = CD.[Id]
					FROM @IdByFilterType CD
				) D
				CROSS JOIN @UsedFilterTypes C
				LEFT JOIN @IdByFilterType CD ON CD.[Type] = C.[Type] AND CD.[Id] = D.[Id]
				GROUP BY D.[Id]
				HAVING Count(*) = Count(CD.[Id])
			) D;
		END;

		SELECT TOP (@RowCount)
			D.ID, D.DATE, U.CAPTION, CL_NAME, D.NOTE, T.NAME AS CLIENT_TYPE,
			S.DATE AS STATUS_DATE, S.CAPTION AS ST_CAPTION, S.NOTE AS STATUS_NOTE, INDX, STATUS_NAME, S.PSEDO, UPDATING,
			V.NAME AS VEN_NAME,
			CASE
				WHEN IS_MEMBER('gr_admin') = 1 OR IS_MEMBER('gr_claim_executor') = 1 THEN 1
				ELSE 0
			END AS IS_EXECUTOR,
			CASE
				WHEN U.NAME = ORIGINAL_LOGIN() THEN 1
				ELSE 0
			END AS IS_AUTHOR,
			SALE_PERSONAL,
			[DISTRS]
		FROM @IDs AS I
		INNER JOIN [Claim].[Document]	AS D ON D.[ID] = I.[Id]
		INNER JOIN [Security].[Users]	AS U ON U.[ID] = D.[ID_AUTHOR]
		INNER JOIN [Claim].[ClientType] AS T ON T.[ID] = D.[ID_TYPE]
		INNER JOIN [Claim].[Vendor]		AS V ON V.[ID] = D.[ID_VENDOR]
		CROSS APPLY
		(
			SELECT TOP (1)
				DS.[DATE], U.[CAPTION], DS.[NOTE], S.[STATUS_NAME], S.[INDX], S.[PSEDO], S.[UPDATING]
			FROM [Claim].[DocumentStatus]	AS DS
			INNER JOIN [Security].[Users]	AS U ON U.[ID] = DS.[ID_AUTHOR]
			INNER JOIN [Claim].[StatusView] AS S ON S.[STATUS] = DS.[STATUS]
			WHERE DS.[ID_DOCUMENT] = D.[ID]
			ORDER BY
				DS.[DATE] DESC
		) AS S
		OUTER APPLY
		(
			SELECT
			    [DISTRS] =
			        CASE
						WHEN D.[CL_TYPE] = 'OIS' THEN
							Reverse(Stuff(Reverse(
								(
									SELECT TOP (10)
										[DistrStr] + ' (' + [DistrTypeName] + '),'
									FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[ClientDistrView] AS CD WITH(NOEXPAND)
									WHERE D.[CL_TYPE] = 'OIS'
										AND CD.[ID_CLIENT] = D.[ID_CLIENT]
										AND CD.[DS_REG] = 0
									ORDER BY CD.[SystemOrder], CD.[DISTR], CD.[COMP] FOR XML PATH('')
								)), 1, 1, ''))
						ELSE NULL
					END
		) AS CD
		ORDER BY D.[DATE] DESC, D.[CL_NAME];

		SELECT @RC = @@ROWCOUNT

		EXEC Maintenance.FINISH_PROC @@PROCID
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Maintenance.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_SELECT] TO rl_claim_r;
GO
