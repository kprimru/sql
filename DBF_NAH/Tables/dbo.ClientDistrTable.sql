USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDistrTable]
(
        [CD_ID]           Int             Identity(1,1)   NOT NULL,
        [CD_ID_CLIENT]    Int                             NOT NULL,
        [CD_ID_DISTR]     Int                             NOT NULL,
        [CD_REG_DATE]     SmallDateTime                       NULL,
        [CD_ID_SERVICE]   SmallInt                            NULL,
        CONSTRAINT [PK_dbo.ClientDistrTable] PRIMARY KEY NONCLUSTERED ([CD_ID]),
        CONSTRAINT [FK_dbo.ClientDistrTable(CD_ID_SERVICE)_dbo.DistrServiceStatusTable(DSS_ID)] FOREIGN KEY  ([CD_ID_SERVICE]) REFERENCES [dbo].[DistrServiceStatusTable] ([DSS_ID]),
        CONSTRAINT [FK_dbo.ClientDistrTable(CD_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CD_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ClientDistrTable(CD_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([CD_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientDistrTable(CD_ID_CLIENT,CD_ID_SERVICE)] ON [dbo].[ClientDistrTable] ([CD_ID_CLIENT] ASC, [CD_ID_SERVICE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrTable(CD_ID_SERVICE)+(CD_ID,CD_ID_CLIENT,CD_ID_DISTR)] ON [dbo].[ClientDistrTable] ([CD_ID_SERVICE] ASC) INCLUDE ([CD_ID], [CD_ID_CLIENT], [CD_ID_DISTR]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrTable(CD_REG_DATE,CD_ID,CD_ID_DISTR)] ON [dbo].[ClientDistrTable] ([CD_REG_DATE] ASC, [CD_ID] ASC, [CD_ID_DISTR] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ClientDistrTable(CD_ID_DISTR)] ON [dbo].[ClientDistrTable] ([CD_ID_DISTR] ASC);
GO
GRANT SELECT ON [dbo].[ClientDistrTable] TO rl_all_r;
GRANT SELECT ON [dbo].[ClientDistrTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[ClientDistrTable] TO rl_client_r;
GRANT SELECT ON [dbo].[ClientDistrTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[ClientDistrTable] TO rl_to_r;
GO
