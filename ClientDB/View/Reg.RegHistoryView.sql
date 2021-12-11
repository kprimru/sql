USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegHistoryView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegHistoryView]  AS SELECT 1')
GO
ALTER VIEW [Reg].[RegHistoryView]
WITH SCHEMABINDING
AS
	SELECT
		ID, ID_DISTR, DATE,
		SystemShortName, NT_SHORT, SST_SHORT,
		SUBHOST, TRAN_COUNT, TRAN_LEFT,
		DS_NAME, DS_REG, REG_DATE, FIRST_REG, COMPLECT, COMMENT
	FROM
		Reg.RegHistory
		INNER JOIN dbo.SystemTable ON ID_SYSTEM = SystemID
		INNER JOIN Din.SystemType ON ID_TYPE = SST_ID
		INNER JOIN Din.NetType ON ID_NET = NT_ID
		INNER JOIN dbo.DistrStatus ON ID_STATUS = DS_ID

GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegHistoryView(ID)] ON [Reg].[RegHistoryView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Reg.RegHistoryView(ID_DISTR,DATE)+INCL] ON [Reg].[RegHistoryView] ([ID_DISTR] ASC, [DATE] ASC) INCLUDE ([COMMENT], [COMPLECT], [DS_NAME], [DS_REG], [FIRST_REG], [ID], [NT_SHORT], [REG_DATE], [SST_SHORT], [SUBHOST], [SystemShortName], [TRAN_COUNT], [TRAN_LEFT]);
GO
