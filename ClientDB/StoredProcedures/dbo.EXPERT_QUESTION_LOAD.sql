USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EXPERT_QUESTION_LOAD]
	@CPL	NVARCHAR(128),
	@DT		DATETIME,
	@FIO	NVARCHAR(256),
	@PHONE	NVARCHAR(128),
	@EMAIL	NVARCHAR(128),
	@QUEST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @TBL Table
	(
		Id UniqueIdentifier NOT NULL PRIMARY KEY CLUSTERED
	);
	
	DECLARE
		@SystemNumber	Int,
		@DistrNumber	Int,
		@CompNumber		TinyInt,
		@Host_Id		SmallInt,
		@CallDirection_Id UniqueIdentifier,
		@Id				UniqueIdentifier,
		@Duty_Id		Int,
		@Client_Id		Int;
	

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @DT = DATEADD(HOUR, 7, @DT);
		
		SELECT
			@SystemNumber	= C.[SystemNumber],
			@DistrNumber	= C.[DistrNumber],
			@CompNumber		= C.[CompNumber]
		FROM dbo.Complect@Parse(@CPL) AS C;
		
		SELECT @Host_Id = HostID
		FROM dbo.SystemTable
		WHERE SystemNumber = @SystemNumber
			AND SystemRic = 20;

		INSERT INTO dbo.ClientDutyQuestion(SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST)
		OUTPUT inserted.ID INTO @TBL
		SELECT SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, REPLACE(QUEST, CHAR(10), '')
		FROM
		(
			SELECT
				@SystemNumber AS SYS,
				@DistrNumber AS DISTR,
				@CompNumber AS COMP,
				@DT AS DATE,
				@FIO AS FIO,
				@EMAIL AS EMAIL,
				@PHONE AS PHONE,
				@QUEST AS QUEST
		) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyQuestion b
				WHERE	a.SYS = b.SYS
					AND a.DISTR = b.DISTR
					AND a.COMP = b.COMP
					AND a.DATE = b.DATE
					AND a.FIO = b.FIO
					AND a.EMAIL = b.EMAIL
					AND a.PHONE = b.PHONE
					AND
						(
								REPLACE(a.QUEST, CHAR(10), '') = b.QUEST
							OR
								a.QUEST = b.QUEST
						)
			);
				
		SELECT @ID = ID FROM @TBL
		
		SELECT @Duty_Id = DutyID
		FROM dbo.DutyTable
		WHERE DutyLogin = 'Автомат';
		
		IF @Duty_Id IS NULL
			SELECT TOP 1 @Duty_Id = DutyID
			FROM dbo.DutyTable;
		
		SET @CallDirection_Id = 
			(
				SELECT TOP 1 ID
				FROM dbo.CallDirection
				WHERE NAME = 'ВопросЭксперту'
			);
		
		SET @Client_Id =
			(
				SELECT TOP (1) ID_CLIENT
				FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
				WHERE	D.[DISTR] = @DistrNumber
					AND D.[COMP] = @CompNumber
					AND D.[HostId] = @Host_Id
			);
		
		
		IF @Client_Id IS NULL AND 
			(
				SELECT TOP (1) SubhostName 
				FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
				WHERE b.DistrNumber = @DistrNumber
					AND b.CompNumber = @CompNumber
					AND b.HostId = @Host_Id
			) = 'Л1'
			-- ToDo - убрать злостный хардкод (Id славянки)
			SET @Client_Id = 3103
			
		IF @Client_Id IS NOT NULL BEGIN
			INSERT INTO dbo.ClientDutyTable(ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone, DutyID, ClientDutyQuest, EMAIL, 
					ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
			SELECT 
				@Client_Id, a.DATE, a.FIO, a.PHONE, @Duty_Id, a.QUEST, a.EMAIL, 0, '', 0, '', @CallDirection_Id
			FROM dbo.ClientDutyQuestion a
			WHERE	a.ID = @ID
				AND a.IMPORT IS NULL;
				
			UPDATE a
			SET IMPORT = GETDATE()
			FROM dbo.ClientDutyQuestion a
			WHERE	a.ID = @ID
				AND a.IMPORT IS NULL;
		END;
				
		UPDATE a
		SET IMPORT = GETDATE()
		FROM
			dbo.ClientDutyQuestion a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
		WHERE a.IMPORT IS NULL AND DATE >= '20170801'	
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
