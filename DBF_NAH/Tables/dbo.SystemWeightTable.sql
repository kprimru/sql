USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemWeightTable]
(
        [SW_ID]          Int        Identity(1,1)   NOT NULL,
        [SW_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SW_ID_PERIOD]   SmallInt                   NOT NULL,
        [SW_WEIGHT]      decimal                    NOT NULL,
        [SW_PROBLEM]     Bit                            NULL,
        [SW_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.SystemWeightTable] PRIMARY KEY CLUSTERED ([SW_ID]),
        CONSTRAINT [FK_dbo.SystemWeightTable(SW_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SW_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SystemWeightTable(SW_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([SW_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemWeightTable(SW_ID_PERIOD,SW_ID_SYSTEM,SW_PROBLEM)+(SW_WEIGHT)] ON [dbo].[SystemWeightTable] ([SW_ID_PERIOD] ASC, [SW_ID_SYSTEM] ASC, [SW_PROBLEM] ASC) INCLUDE ([SW_WEIGHT]);
GO
