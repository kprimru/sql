USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[NET_TYPE_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT	=	MAX(NTMS_LAST)
	FROM	Distr.NetType
END
GO
GRANT EXECUTE ON [Distr].[NET_TYPE_LAST] TO rl_net_type_r;
GO