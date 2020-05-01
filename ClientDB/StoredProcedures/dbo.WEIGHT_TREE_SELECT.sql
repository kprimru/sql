USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
			SELECT DISTINCT SystemShortName, SystemBaseName
			FROM dbo.SystemTable S
			INNER JOIN dbo.Weight W ON S.SystemBaseName = W.Sys
			WHERE @SYS IS NULL OR @SYS = SystemShortName
		) AS Systems
		CROSS JOIN
		(
			SELECT DISTINCT SST_SHORT, SST_REG
			FROM Din.SystemType S
			INNER JOIN dbo.Weight W ON S.SST_REG = W.SysType
			WHERE @SYS_TYPE IS NULL OR SST_SHORT = @SYS_TYPE
		) AS SystemTypes
		CROSS JOIN
		(
			SELECT DISTINCT NT_SHORT, NT_TECH, NT_NET, NT_ODON, NT_ODOFF
			FROM Din.NetType N
			INNER JOIN dbo.Weight W ON N.NT_NET = W.NetCount AND N.NT_TECH = W.NetTech AND N.NT_ODON = W.NetOdon AND N.NT_ODOFF = W.NetOdoff
			WHERE @NET_TYPE IS NULL OR NT_SHORT = @NET_TYPE
		) AS NetTypes
		CROSS APPLY
		(
			SELECT TOP 1 Date, Weight
			FROM dbo.Weight W
			WHERE W.Sys = Systems.SystemBaseName
				AND W.SysType = SystemTypes.SST_REG
				AND W.NetCount = NetTypes.NT_NET
				AND W.NetTech = NetTypes.NT_TECH
				AND W.NetOdon = NetTypes.NT_ODON
				AND W.NetOdoff = NetTypes.NT_ODOFF
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

		-- заполн€ем системы
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

		-- заполн€ем сетевитость и вес дл€ нее
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

	-----------------------‘»Ћ№“–-----------------------------------------------------

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
	---------------------- ќЌ≈÷ ‘»Ћ№“–ј---------------------------------------------

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

GRANT EXECUTE ON [dbo].[WEIGHT_TREE_SELECT] TO rl_weights_tree_select;
GO