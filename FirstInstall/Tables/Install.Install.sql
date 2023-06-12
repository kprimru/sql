USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Install].[Install]
(
        [INS_ID]          UniqueIdentifier      NOT NULL,
        [INS_ID_CLIENT]   UniqueIdentifier      NOT NULL,
        [INS_ID_VENDOR]   UniqueIdentifier      NOT NULL,
        [INS_DATE]        SmallDateTime         NOT NULL,
        CONSTRAINT [PK_Install.Install] PRIMARY KEY CLUSTERED ([INS_ID]),
        CONSTRAINT [FK_Install.Install(INS_ID_CLIENT)_Install.Clients(CLMS_ID)] FOREIGN KEY  ([INS_ID_CLIENT]) REFERENCES [Clients].[Clients] ([CLMS_ID]),
        CONSTRAINT [FK_Install.Install(INS_ID_VENDOR)_Install.Vendors(VDMS_ID)] FOREIGN KEY  ([INS_ID_VENDOR]) REFERENCES [Clients].[Vendors] ([VDMS_ID])
);
GO
