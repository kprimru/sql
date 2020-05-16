USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ODD_DIN_MANAGER_SAVE]
	@Host_Id	SmallInt,
	@Distr		Int,
	@Comp		TinyInt,
	@Manager_Id	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	INSERT INTO Client.ManagerOdd(Manager_Id, Host_Id, Distr, Comp)
	VALUES(@Manager_Id, @Host_Id, @Distr, @Comp)
END

GO
GRANT EXECUTE ON [dbo].[ODD_DIN_MANAGER_SAVE] TO rl_odd_manager;
GO