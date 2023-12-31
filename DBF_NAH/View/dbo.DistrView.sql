USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrView]
WITH SCHEMABINDING
AS
	SELECT
		SYS_ID, SYS_SHORT_NAME, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_NAME,
		SYS_MAIN, SYS_1C_CODE, SYS_1C_CODE2, SYS_IB, SYS_REPORT, SYS_PREFIX,
		HST_ID, HST_REG_NAME,
		DIS_NUM, DIS_COMP_NUM, DIS_ID, DIS_ACTIVE,
		CASE DIS_COMP_NUM
			WHEN 1 THEN SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR, DIS_NUM)
			ELSE SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR, DIS_NUM) + '/' + CONVERT(VARCHAR, DIS_COMP_NUM)
		END AS DIS_STR
	FROM dbo.SystemTable
	INNER JOIN dbo.DistrTable ON SYS_ID = DIS_ID_SYSTEM
	INNER JOIN dbo.HostTable ON SYS_ID_HOST = HST_ID

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.DistrView(DIS_ID)] ON [dbo].[DistrView] ([DIS_ID] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.DistrView(DIS_NUM,SYS_ID,DIS_COMP_NUM)] ON [dbo].[DistrView] ([DIS_NUM] ASC, [SYS_ID] ASC, [DIS_COMP_NUM] ASC);
GO
GRANT SELECT ON [dbo].[DistrView] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[DistrView] TO rl_client_r;
GRANT SELECT ON [dbo].[DistrView] TO rl_fin_r;
GRANT SELECT ON [dbo].[DistrView] TO rl_to_r;
GO
