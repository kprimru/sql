USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TOTable]
(
        [TO_ID]            Int            Identity(1,1)   NOT NULL,
        [TO_ID_CLIENT]     Int                            NOT NULL,
        [TO_NAME]          VarChar(250)                   NOT NULL,
        [TO_NUM]           Int                            NOT NULL,
        [TO_REPORT]        Bit                            NOT NULL,
        [TO_ID_COUR]       SmallInt                           NULL,
        [TO_VMI_COMMENT]   VarChar(250)                   NOT NULL,
        [TO_MAIN]          Bit                                NULL,
        [TO_INN]           VarChar(20)                    NOT NULL,
        [TO_LAST]          DateTime                           NULL,
        [TO_PARENT]        Int                                NULL,
        [TO_RANGE]         decimal                            NULL,
        [TO_DELETED]       Bit                            NOT NULL,
        [TO_SALARY]        Money                              NULL,
        CONSTRAINT [PK_dbo.TOTable] PRIMARY KEY NONCLUSTERED ([TO_ID]),
        CONSTRAINT [FK_dbo.TOTable(TO_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([TO_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.TOTable(TO_ID_COUR)_dbo.CourierTable(COUR_ID)] FOREIGN KEY  ([TO_ID_COUR]) REFERENCES [dbo].[CourierTable] ([COUR_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.TOTable(TO_ID_CLIENT,TO_ID_COUR,TO_ID)] ON [dbo].[TOTable] ([TO_ID_CLIENT] ASC, [TO_ID_COUR] ASC, [TO_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.TOTable(TO_ID_COUR)+(TO_ID_CLIENT,TO_ID)] ON [dbo].[TOTable] ([TO_ID_COUR] ASC) INCLUDE ([TO_ID_CLIENT], [TO_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOTable(TO_MAIN)+(TO_ID_CLIENT)] ON [dbo].[TOTable] ([TO_MAIN] ASC) INCLUDE ([TO_ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOTable(TO_NAME)+(TO_ID,TO_ID_COUR)] ON [dbo].[TOTable] ([TO_NAME] ASC) INCLUDE ([TO_ID], [TO_ID_COUR]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOTable(TO_REPORT)+(TO_ID)] ON [dbo].[TOTable] ([TO_REPORT] ASC) INCLUDE ([TO_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.TOTable(TO_REPORT,TO_ID,TO_ID_CLIENT)+(TO_NAME,TO_NUM,TO_VMI_COMMENT)] ON [dbo].[TOTable] ([TO_REPORT] ASC, [TO_ID] ASC, [TO_ID_CLIENT] ASC) INCLUDE ([TO_NAME], [TO_NUM], [TO_VMI_COMMENT]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TOTable(TO_NUM)] ON [dbo].[TOTable] ([TO_NUM] ASC);
GO
GRANT SELECT ON [dbo].[TOTable] TO rl_all_r;
GRANT SELECT ON [dbo].[TOTable] TO rl_client_fin_r;
GRANT SELECT ON [dbo].[TOTable] TO rl_client_r;
GRANT SELECT ON [dbo].[TOTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[TOTable] TO rl_to_r;
GO
