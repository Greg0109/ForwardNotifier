using System.IO;
using System;
using System.Net;
using System.Threading;
using System.Diagnostics;
using System.Security.Principal;
using System.Linq.Expressions;
using System.Net.Http.Headers;
using System.Reflection;

namespace ForwardNotifierSetup
{
    class Program
    {
        static string PythonDirectory = "";

        static bool DownloadCompleted = false;

        static bool IsBusy = false;

        static void Main(string[] args)
        {
            Console.Clear();
            Console.SetCursorPosition(0, 0);
            if (IsAdministrator())
            {
                if (args.Length == 0)
                {
                    NoArgsMain();
                }
                else if (args.Length == 2)
                {
                    if (args[0] == "-pd" && Directory.Exists(args[1]))
                    {
                        PythonDirectory = args[1];
                        Console.WriteLine("Downloading necessary modules, please wait...");
                        DownloadModules();
                        Console.WriteLine("Done, unzipping packages.");
                        GetServerPy();
                    }

                    else if (args[0] == "-uninstall" && args[1] == "-py")
                    {
                        try
                        {
                            Console.WriteLine("Uninstalling server. . .");
                            Process[] p = Process.GetProcessesByName("Python");
                            foreach (var i in p)
                                i.Kill();
                            File.Delete($"{Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData)}\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp\\Server.pyw");
                            Console.WriteLine("Downloading python to uninstall python.");
                            DownloadPython();
                            Console.WriteLine("Uninstalling. . .");
                            Process pr = Process.Start(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\python-setup.exe", "/uninstall");
                            pr.WaitForExit();
                            Console.WriteLine("Done uninstalling!");

                        }
                        catch (Exception)
                        {
                            Console.WriteLine("Unable to uninstall. . .");
                        }
                    }
                }
                else if (args.Length == 1)
                {
                    if (args[0] == "-uninstall")
                    {
                        try
                        {
                            Console.WriteLine("Uninstalling server. . .");
                            Process[] p = Process.GetProcessesByName("Python");
                            foreach (var i in p)
                                i.Kill();
                            File.Delete($"{Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData)}\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp\\Server.pyw");
                            Console.WriteLine("Successfully uninstalled!");
                        }
                        catch (Exception)
                        {
                            Console.WriteLine("Unable to uninstall. . .");
                        }
                        Console.ReadKey(true);
                    }
                }
            }
            else
            {
                Console.WriteLine("Please run this program as administrator...");
                Console.ReadKey(true);
            }
        }

        static void NoArgsMain()
        {
            Console.WriteLine("Installing ForwardNotifier. . .");
            Console.WriteLine("Checking if python is installed.");

            string userApps = $@"{Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)}\Programs";

            if (!Directory.Exists(userApps + "\\Python"))
            {
                DownloadPython();
            }

            try
            {
                DirectoryInfo directories = new DirectoryInfo(userApps + @"\Python");
                foreach (var i in directories.GetDirectories())
                {
                    if (i.Name == "Launcher")
                        continue;
                    else
                    {
                        PythonDirectory = i.FullName;
                        break;
                    }
                }
            }
            catch (Exception)
            {
                Console.WriteLine("Python directory not found. Press any key to run python setup else exit and contact dev.");
                Console.ReadKey(true);
                Console.Clear();
                DownloadPython();
                DirectoryInfo directories = new DirectoryInfo(userApps + @"\Python");
                foreach (var i in directories.GetDirectories())
                {
                    if (i.Name == "Launcher")
                        continue;
                    else
                    {
                        PythonDirectory = i.FullName;
                        break;
                    }
                }
            }
            Console.WriteLine("Downloading necessary modules, please wait...");
            DownloadModules();
            Console.WriteLine("Done, unzipping packages.");
            GetServerPy();
        }

        static void GetServerPy()
        {
            using (WebClient client = new WebClient())
            {
                client.DownloadFile("https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py", $"{Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData)}\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp\\Server.pyw");
            }
            try
            {
                Process.Start($"{Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData)}\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp\\Server.pyw");
            }
            catch (System.ComponentModel.Win32Exception)
            {
                Console.WriteLine("Unable to start the file. No big deal, just reboot and it will work!");
            }
            Console.WriteLine("Done!");
            Console.ReadKey(true);
        }

        static void DownloadModules()
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = PythonDirectory + @"\Scripts\pip.exe";
            psi.Arguments = "install win10toast";
            psi.UseShellExecute = false;
            Process p = new Process();
            p.StartInfo = psi;
            p.Start();
            p.WaitForExit();
        }

        static void DownloadPython()
        {
            Console.WriteLine("Python is not installed, installing python... please wait.");
            using (WebClient client = new WebClient())
            {
                Console.CursorVisible = false;
                client.DownloadProgressChanged += Client_DownloadProgressChanged;
                client.DownloadFileCompleted += Client_DownloadFileCompleted;
                client.DownloadFileAsync(new Uri(Environment.Is64BitOperatingSystem ? "https://www.python.org/ftp/python/3.8.3/python-3.8.3-amd64.exe" : "https://www.python.org/ftp/python/3.8.3/python-3.8.3.exe"), Path.Combine(Directory.GetCurrentDirectory(), "python-setup.exe"));
                while (!DownloadCompleted)
                    Thread.Sleep(1000);
            }
            Console.CursorVisible = true;
            Console.WriteLine("Download completed. Running installer.");
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = Path.Combine(Directory.GetCurrentDirectory(), "python-setup.exe");
            psi.UseShellExecute = true;
            psi.Arguments = "/passive InstallLauncherAllUsers=0 PrependPath=1 Include_pip=1 Include_test=0";
            Process p = new Process();
            p.StartInfo = psi;
            p.Start();
            p.WaitForExit();
        }

        private static void Client_DownloadFileCompleted(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
        {
            DownloadCompleted = true;
            Console.SetCursorPosition(0, 3);
        }

        private static void Client_DownloadProgressChanged(object sender, DownloadProgressChangedEventArgs e)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                Console.SetCursorPosition(0, 3);
                if (e.ProgressPercentage < 10)
                {
                    Console.Write("[          ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 20)
                {
                    Console.Write("[#         ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 30)
                {
                    Console.Write("[##        ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 40)
                {
                    Console.Write("[###       ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 50)
                {
                    Console.Write("[####      ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 60)
                {
                    Console.Write("[#####     ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 70)
                {
                    Console.Write("[######    ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 80)
                {
                    Console.Write("[#######   ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 90)
                {
                    Console.Write("[########  ] " + e.ProgressPercentage + "%");
                }
                else if (e.ProgressPercentage < 100)
                {
                    Console.Write("[######### ] " + e.ProgressPercentage + "%");
                }
                else
                {
                    Console.Write("[##########] " + e.ProgressPercentage + "%");
                }
                IsBusy = false;
            }
        }

        public static bool IsAdministrator()
        {
            return (new WindowsPrincipal(WindowsIdentity.GetCurrent()))
                      .IsInRole(WindowsBuiltInRole.Administrator);
        }
    }
}
