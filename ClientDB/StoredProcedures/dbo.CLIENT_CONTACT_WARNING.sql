USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTACT_WARNING]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTACT_WARNING]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_CONTACT_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Statuses Table (Id SmallInt Primary Key Clustered);
	DECLARE @ManagerExclude Table (Id Int Primary Key Clustered);
	DECLARE @ClientKind Table (Id SmallInt Primary Key Clustered);
	DECLARE @ContactType Table (Id UniqueIdentifier Primary Key Clustered);
	DECLARE @ClientWrite Table (Id Int Primary Key Clustered);

	DECLARE @ControlDate	SmallDateTime;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SET @ControlDate = dbo.DateOf(DateAdd(DAY, -180, GetDate()))

		INSERT INTO @Statuses
		SELECT ServiceStatusId
		FROM [dbo].[ServiceStatusConnected]();

		INSERT INTO @ManagerExclude
		SELECT Cast(SetItem AS Int)
		FROM dbo.NamedSetItemsSelect('dbo.ManagerTable', 'Не учитывать в контроле посещения');

		INSERT INTO @ClientKind
		SELECT Cast(SetItem AS SmallInt)
		FROM dbo.NamedSetItemsSelect('dbo.ClientKind', 'DefaultChecked');

		INSERT INTO @ContactType
		SELECT Cast(SetItem AS UniqueIdentifier)
		FROM dbo.NamedSetItemsSelect('dbo.ClientContactType', 'Посещение');

		INSERT INTO @ClientWrite
		SELECT WCL_ID
		FROM dbo.[ClientList@Get?Write]() a;

		SELECT b.ClientID, b.ClientFullName, b.ServiceId, b.ManagerId, b.ClientKind_Id, b.ClientTypeId, LAST_DATE
		FROM @ClientWrite W
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON W.Id = ClientID
		INNER JOIN @ClientKind K ON K.[Id] = b.ClientKind_Id
		INNER JOIN @Statuses s ON b.ServiceStatusId = s.Id
		OUTER APPLY
		(
			SELECT TOP (1)
				[LAST_DATE] = dbo.Dateof(DATE)
			FROM dbo.ClientContact cc
			INNER JOIN @ContactType T ON T.[Id] = CC.[ID_TYPE]
			WHERE STATUS = 1
				AND ID_CLIENT = b.ClientID
			ORDER BY DATE DESC
		) LD
		WHERE	ManagerId NOT IN (SELECT M.[Id] FROM @ManagerExclude M)
			AND (LAST_DATE IS NULL OR LAST_DATE < @ControlDate)
		ORDER BY ISNULL(LAST_DATE, GETDATE()) DESC, LAST_DATE DESC, ManagerId, ServiceId
		OPTION(RECOMPILE);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTACT_WARNING] TO rl_contact_warning;
GO
