USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.08.2008
Описание:	  Изменить данные о типе сети с
               указанным кодом
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COUNT_EDIT]
	@systemnetcountid SMALLINT,
	@systemnetid SMALLINT,
	@netcount INT,
	@tech INT,
	@ODOFF	SMALLINT,
	@ODON	SMALLINT,
	@SHORT	VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.SystemNetCountTable
	SET SNC_ID_SN = @systemnetid,
		SNC_NET_COUNT = @netcount,
		SNC_TECH = @tech,
		SNC_ODON = @ODON,
		SNC_ODOFF = @ODOFF,
		SNC_SHORT = @SHORT,
		SNC_ACTIVE = @active
	WHERE SNC_ID = @systemnetcountid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COUNT_EDIT] TO rl_system_net_count_w;
GO