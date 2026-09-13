import './globals.css';
import {QueryProvider} from '@/components/query-provider';
import {ToastProvider} from '@/components/toast';
import {ThemeProvider} from '@/components/theme-provider';

export default function RootLayout({children}:{children:React.ReactNode}){
  return <html lang="en"><body className="theme-bg"><ThemeProvider><QueryProvider><ToastProvider>{children}</ToastProvider></QueryProvider></ThemeProvider></body></html>;
}
