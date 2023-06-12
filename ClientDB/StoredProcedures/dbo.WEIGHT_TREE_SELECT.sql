USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[WEIGHT_TREE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[WEIGHT_TREE_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[WEIGHT_TREE_SELECT]
	@SYS		VARCHAR(20)	=	NULL,
	@SYS_TYPE	VARCHAR(20)	=	NULL,
	@NET_TYPE	VARCHAR(20)	=	NULL,
	@DATE		DATETIME
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

		DECLARE @WParams Table
		(
			[Sys]       VarChar(50)     NOT NULL,
			[SysType]   VarChar(50)     NOT NULL,
			[NetType]   VarChar(50)     NOT NULL,
			[Date]      DateTime        NOT NULL,
			[Weight]    Decimal(8,4)		NULL,
			Primary Key Clustered([Sys], [SysType], [NetType], [Date])
		);

		INSERT INTO @WParams
		SELECT Systems.SystemShortName, SystemTypes.SST_SHORT, NetTypes.NT_SHORT, W.Date, W.Weight
		FROM
		(
			SELECT DISTINCT SystemShortName, SystemBaseName, SystemID
			FROM dbo.SystemTable S
			INNER JOIN dbo.Weight W ON S.SystemID = W.System_Id
			WHERE @SYS IS NULL OR @SYS = SystemShortName
		) AS Systems
		CROSS JOIN
		(
			SELECT DISTINCT SST_SHORT, SST_REG, SST_ID
			FROM Din.SystemType S
			INNER JOIN dbo.Weight W ON S.SST_ID = W.SystemType_Id
			WHERE @SYS_TYPE IS NULL OR SST_SHORT = @SYS_TYPE
		) AS SystemTypes
		CROSS JOIN
		(
			SELECT DISTINCT NT_SHORT, NT_TECH, NT_NET, NT_ODON, NT_ODOFF, NT_ID
			FROM Din.NetType N
			INNER JOIN dbo.Weight W ON N.NT_ID = W.NetType_Id
			WHERE @NET_TYPE IS NULL OR NT_SHORT = @NET_TYPE
		) AS NetTypes
		CROSS APPLY
		(
			SELECT TOP 1 Date, Weight
			FROM dbo.Weight W
			WHERE W.System_Id = Systems.SystemID
				AND W.SystemType_Id = SystemTypes.SST_ID
				AND W.NetType_Id = NetTypes.NT_ID
				AND W.Date < ISNULL(@DATE, GETDATE())
			ORDER BY Date DESC
		) W;

		DECLARE @Data Table
		(
			[Systems]   VarChar(Max)	NOT NULL,
			[Types]     VarChar(Max)	NOT NULL,
			[Nets]      VarChar(Max)	NOT NULL,
			[Weight]    Decimal(8,4)
		);

		INSERT INTO @Data
		SELECT DISTINCT
			[SystemGroups]      = SWT.[SystemGroups],
			[SystemTypesGroups] = SWT.[SystemTypesGroups],
			[NetTypeGroups]     =
						(
							REVERSE(STUFF(REVERSE(
								(
									SELECT [NetType] + ','
									FROM
									(
										SELECT DISTINCT S.[NetType]
										FROM @WParams S
										WHERE S.[Weight] = SWT.[Weight]
											AND (SWT.[SystemGroups] LIKE '%'+S.[Sys]+'%' OR SWT.[SystemGroups] LIKE '%,'+S.[Sys] OR SWT.[SystemGroups] LIKE S.[Sys]+',%')
											AND (SWT.[SystemTypesGroups] LIKE '%'+S.[SysType]+'%' OR SWT.[SystemTypesGroups] LIKE '%,'+S.[SysType] OR SWT.[SystemTypesGroups] LIKE S.[SysType]+',%')
									) AS X
									FOR XML PATH('')
								)), 1, 1, ''))
						),
			[Weight]            = SWT.[Weight]
		FROM
		(
			SELECT DISTINCT
				[SystemGroups] = SW.[SystemGroups],
				[SystemTypesGroups] =
						(
							REVERSE(STUFF(REVERSE(
								(
									SELECT [SysType] + ','
									FROM
									(
										SELECT DISTINCT S.[SysType]
										FROM @WParams S
										WHERE S.[Weight] = SW.[Weight]
											AND (SW.[SystemGroups] LIKE '%'+S.[Sys]+'%' OR SW.[SystemGroups] LIKE '%,'+S.[Sys] OR SW.[SystemGroups] LIKE S.[Sys]+',%')
									) AS X
									FOR XML PATH('')
								)), 1, 1, ''))
						),
				[Weight]       = SW.[Weight]
			FROM
			(
				SELECT DISTINCT
					[SystemGroups] =
						(
							REVERSE(STUFF(REVERSE(
								(
									SELECT [Sys] + ','
									FROM
									(
										SELECT DISTINCT S.[Sys]
										FROM @WParams S
										WHERE S.[Weight] = P.[Weight]
									) AS X
									FOR XML PATH('')
								)), 1, 1, ''))
						),
					[Weight] = P.[Weight]
				FROM @WParams P
			) SW
		) SWT
		-------------------------------------------------------------------------------------------
		DECLARE @Result Table
		(
			[Id]        Int             Identity(1,1)   NOT NULL,
			[Parent_Id] Int                                 NULL,
			[Data]      NVarChar(MAX)                    NOT NULL,
			[Weight]    Decimal(8,4)                        NULL,
			PRIMARY KEY CLUSTERED ([Id])
		);

		-- заполняем системы
		INSERT INTO @Result([Data])
		SELECT DISTINCT
			[Systems]
		FROM @Data;

		-- заполнем типы систем
		INSERT INTO @Result([Parent_Id], [Data])
		SELECT R.[Id], [Types]
		FROM
		(
			SELECT DISTINCT [Systems], [Types]
			FROM @Data
		) D
		INNER JOIN @Result R ON R.[Data] = D.[Systems] AND R.[Parent_Id] IS NULL;

		-- заполняем сетевитость и вес для нее
		INSERT INTO @Result([Parent_Id], [Data], [Weight])
		SELECT
			(
				SELECT TOP (1) R.[Id]
				FROM @Result R
				WHERE R.[Data] = D.[Types]
					AND R.[Parent_Id] =
						(
							SELECT TOP (1) [Id]
							FROM @Result S
							WHERE S.[Data] = D.[Systems]
						)
			), D.[Nets], D.[Weight]
		FROM @Data D

	-----------------------ФИЛЬТР-----------------------------------------------------

		IF @SYS IS NOT NULL
		BEGIN
			DELETE FROM @Result
			WHERE	Id NOT IN
			(
				SELECT Id
				FROM @Result
				WHERE (Data LIKE '%,'+@SYS+',%')OR(Data LIKE '%,'+@SYS)OR(Data LIKE @SYS+',%')OR(Data LIKE @SYS)

				UNION ALL

				SELECT Id
				FROM @Result
				WHERE Parent_Id IN
					(
					SELECT Id
					FROM @Result
					WHERE (Data LIKE '%,'+@SYS+',%')OR(Data LIKE '%,'+@SYS)OR(Data LIKE @SYS+',%')OR(Data LIKE @SYS)
					)

				UNION ALL

				SELECT Id
				FROM @Result
				WHERE Parent_ID IN
					(
					SELECT Id
					FROM @Result
					WHERE Parent_Id IN
						(
						SELECT Id
						FROM @Result
						WHERE (Data LIKE '%,'+@SYS+',%')OR(Data LIKE '%,'+@SYS)OR(Data LIKE @SYS+',%')OR(Data LIKE @SYS)
						)
					)
			)
		END

		IF @SYS_TYPE IS NOT NULL
		BEGIN
			DELETE FROM @Result
			WHERE	Id NOT IN
			(
				SELECT Parent_Id
				FROM @Result
				WHERE (Data LIKE '%,'+@SYS_TYPE+',%')OR(Data LIKE '%,'+@SYS_TYPE)OR(Data LIKE @SYS_TYPE+',%')OR(Data LIKE @SYS_TYPE)

				UNION ALL

				SELECT Id
				FROM @Result
				WHERE (Data LIKE '%,'+@SYS_TYPE+',%')OR(Data LIKE '%,'+@SYS_TYPE)OR(Data LIKE @SYS_TYPE+',%')OR(Data LIKE @SYS_TYPE)

				UNION ALL

				SELECT Id
				FROM @Result
				WHERE Parent_Id IN
				(
					SELECT Id
					FROM @Result
					WHERE (Data LIKE '%,'+@SYS_TYPE+',%')OR(Data LIKE '%,'+@SYS_TYPE)OR(Data LIKE @SYS_TYPE+',%')OR(Data LIKE @SYS_TYPE)
				)
			)
		END

		IF @NET_TYPE IS NOT NULL
		BEGIN
			DELETE FROM @Result
			WHERE Id NOT IN
			(
				SELECT Parent_Id
				FROM @Result
				WHERE Id IN
					(
					SELECT Parent_Id
					FROM @Result
					WHERE (Data LIKE '%,'+@NET_TYPE+',%')OR(Data LIKE '%,'+@NET_TYPE)OR(Data LIKE @NET_TYPE+',%')OR(Data LIKE @NET_TYPE)
					)

				UNION ALL

				SELECT Parent_Id
				FROM @Result
				WHERE (Data LIKE '%,'+@NET_TYPE+',%')OR(Data LIKE '%,'+@NET_TYPE)OR(Data LIKE @NET_TYPE+',%')OR(Data LIKE @NET_TYPE)

				UNION ALL

				SELECT Id
				FROM @Result
				WHERE (Data LIKE '%,'+@NET_TYPE+',%')OR(Data LIKE '%,'+@NET_TYPE)OR(Data LIKE @NET_TYPE+',%')OR(Data LIKE @NET_TYPE)
			)
		END
	----------------------КОНЕЦ ФИЛЬТРА---------------------------------------------

		SELECT *
		FROM @Result

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[WEIGHT_TREE_SELECT] TO rl_weights_tree_select;
GO
