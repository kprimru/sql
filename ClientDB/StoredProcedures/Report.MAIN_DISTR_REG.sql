USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[MAIN_DISTR_REG]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @Date           SmallDateTime,
        @MainHost_Id    SmallInt;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @Date = DateAdd(Month, -3, GetDate());

        SELECT @MainHost_Id = HostId
        FROM dbo.Hosts
        WHERE HostReg = 'LAW'

        SELECT
            [Дистрибутив]   = DistrStr,
            [Тип]           = SST_SHORT,
            [Сеть]          = NT_SHORT,
            [Клиент]        = Comment,
            [Дата]          = FirstReg,
            [Статус]        = DS_NAME,
            [Подхост]       = SubhostName
        FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
        WHERE R.HostID = @MainHost_Id
            AND FirstReg >= @Date
            AND SST_SHORT NOT IN ('ОДД')
        ORDER BY FirstReg DESC, CASE WHEN SubhostName = '' THEN 1 ELSE 1 END, SystemOrder, DistrNumber, CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
