USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrDeliveryHistoryTable]
(
        [DDH_ID]              Int             Identity(1,1)   NOT NULL,
        [DDH_ID_DISTR]        Int                             NOT NULL,
        [DDH_ID_OLD_CLIENT]   Int                             NOT NULL,
        [DDH_ID_NEW_CLIENT]   Int                             NOT NULL,
        [DDH_NOTE]            VarChar(100)                        NULL,
        [DDH_USER]            NVarChar(256)                   NOT NULL,
        [DDH_DATE]            DateTime                        NOT NULL,
        CONSTRAINT [PK_dbo.DistrDeliveryHistoryTable] PRIMARY KEY NONCLUSTERED ([DDH_ID]),
        CONSTRAINT [FK_dbo.DistrDeliveryHistoryTable(DDH_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([DDH_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID]),
        CONSTRAINT [FK_dbo.DistrDeliveryHistoryTable(DDH_ID_NEW_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([DDH_ID_NEW_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.DistrDeliveryHistoryTable(DDH_ID_OLD_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([DDH_ID_OLD_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.DistrDeliveryHistoryTable(DDH_ID)] ON [dbo].[DistrDeliveryHistoryTable] ([DDH_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrDeliveryHistoryTable(DDH_ID_DISTR)+INCL] ON [dbo].[DistrDeliveryHistoryTable] ([DDH_ID_DISTR] ASC) INCLUDE ([DDH_ID_OLD_CLIENT], [DDH_ID_NEW_CLIENT], [DDH_USER], [DDH_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrDeliveryHistoryTable(DDH_ID_NEW_CLIENT)+INCL] ON [dbo].[DistrDeliveryHistoryTable] ([DDH_ID_NEW_CLIENT] ASC) INCLUDE ([DDH_ID_DISTR], [DDH_ID_OLD_CLIENT], [DDH_USER], [DDH_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrDeliveryHistoryTable(DDH_ID_OLD_CLIENT)+INCL] ON [dbo].[DistrDeliveryHistoryTable] ([DDH_ID_OLD_CLIENT] ASC) INCLUDE ([DDH_ID_DISTR], [DDH_ID_NEW_CLIENT], [DDH_USER], [DDH_DATE]);
GO
