USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EXPERT_QUESTION_APPLY_CLIENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EXPERT_QUESTION_APPLY_CLIENT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[EXPERT_QUESTION_APPLY_CLIENT]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@CallDirection_Id UniqueIdentifier,
		@Duty_Id		Int;

	DECLARE @IDs Table(Id	UniqueIdentifier PRIMARY KEY CLUSTERED);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

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

		INSERT INTO @IDs
		SELECT a.ID
		FROM dbo.ClientDutyQuestion a
		OUTER APPLY
		(
			SELECT TOP (1) b.ID_CLIENT
			FROM dbo.ClientDistrView b WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
			WHERE a.DISTR = b.DISTR AND a.COMP = b.COMP
		) AS C
		OUTER APPLY
		(
			SELECT TOP (1) SubhostName, SH_ID_CLIENT
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
            LEFT JOIN dbo.Subhost s ON s.SH_REG = b.SubhostName
			WHERE b.DistrNumber = a.DISTR
				AND b.CompNumber = a.COMP
		) AS S
		WHERE a.IMPORT IS NULL --AND a.ID = @ID
            --ToDo Л1 - вынести в свойство dbo.Subhost
			AND (C.ID_CLIENT IS NOT NULL OR C.ID_CLIENT IS NULL AND s.SubhostName = 'Л1')
			AND DATE >= '20170801'

		INSERT INTO dbo.ClientDutyTable(ClientID, ClientDutyDateTime, ClientDutySurname, ClientDutyPhone,
			DutyID,
			ClientDutyQuest, EMAIL,
			ClientDutyNPO, ClientDutyPos, ClientDutyComplete, ClientDutyComment, ID_DIRECTION)
		SELECT
			IsNull(ID_CLIENT, SH_ID_CLIENT), a.DATE, a.FIO, a.PHONE,
			@Duty_Id,
			a.QUEST, a.EMAIL, 0, '', 0, '', @CallDirection_Id
		FROM dbo.ClientDutyQuestion a
		INNER JOIN @IDs AS I ON a.ID = I.Id
		OUTER APPLY
		(
			SELECT TOP (1) b.ID_CLIENT
			FROM dbo.ClientDistrView b WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
			WHERE a.DISTR = b.DISTR AND a.COMP = b.COMP
		) AS C
		OUTER APPLY
		(
			SELECT TOP (1) SubhostName, SH_ID_CLIENT
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
            LEFT JOIN dbo.Subhost s ON s.SH_REG = b.SubhostName
			WHERE b.DistrNumber = a.DISTR
				AND b.CompNumber = a.COMP
		) AS S;

		UPDATE dbo.ClientDutyQuestion SET
			IMPORT = GetDate()
		WHERE ID IN (SELECT I.ID FROM @IDs AS I);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
